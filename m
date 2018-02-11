Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-db5eur01on0106.outbound.protection.outlook.com ([104.47.2.106]:44960
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751862AbeBKGzT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 11 Feb 2018 01:55:19 -0500
From: "Wang, Alan 1. (NSB - CN/Hangzhou)" <alan.1.wang@nokia-sbell.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "neilb@suse.com" <neilb@suse.com>
Subject: A special case in write_flush which cause the umount busy
Date: Sun, 11 Feb 2018 06:55:16 +0000
Message-ID: <VI1PR07MB342127E2A55088F691693A3BA2F00@VI1PR07MB3421.eurprd07.prod.outlook.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a test case on mount/umount on a partition from nfs server side. And=
 encounter a problem of umount busy in a low probability.

The Linux version is 3.10.64 with the patch "sunrpc/cache: make cache flush=
ing more reliable".
https://patchwork.kernel.org/patch/7410021/

After some analysis and test in many times, I find that when it failed to m=
ount, the time "then" and "now" are different, which caused the last_refres=
h is far beyond the flush_time. So this cache is not expired and won't be c=
lean at once.=20
Then the ref in cache_head won't be released, and mntput_no_expire didn't b=
e called to decrease the count. That caused the umount busy.

Below are logs in my test.

kernel: [  292.767801] write_flush 1480 then =3D 249, now =3D 250
kernel: [  292.767817] cache_clean 451, cd name nfsd.fh expiry_time 7904852=
53, cd flush_time 249, last_refresh 369, seconds_since_boot 250
kernel: [  292.767913] write_flush 1480 then =3D 249, now =3D 250
kernel: [  292.767928] cache_clean 451, cd name nfsd.export expiry_time 204=
9, cd flush_time 249, last_refresh 369, seconds_since_boot 250
kernel: [  292.773229] do_refcount_check 283 mycount 4
kernel: [  292.773245] do_umount 1344 retval -16

I think this happens in such case that the exportfs writes the flush with c=
urrent time, the time of "then". But when seconds_since_boot being called i=
n function write_flush, the time is on the next second, so the "now" is one=
 second after "then".
Because "then" is less than "now", the flush_time is set directly to origin=
al "then", rather than "cd->flush_time + 1".


And I want to change the condition as below. I'm not sure it's OK and has n=
o effects to other part.

--------------------------------------------------------------------------
       then =3D get_expiry(&bp);
       now =3D seconds_since_boot();
       cd->nextcheck =3D now;
       /* Can only set flush_time to 1 second beyond "now", or
       * possibly 1 second beyond flushtime.  This is because
       * flush_time never goes backwards so it mustn't get too far
       * ahead of time.
       */
       if (then !=3D now)
              printk("%s %d then =3D %d, now =3D %d\n", __func__, __LINE__,=
 then, now);
-      if (then >=3D now) {
+     if (then >=3D now - 1) {
              /* Want to flush everything, so behave like cache_purge() */
              if (cd->flush_time >=3D now)
                     now =3D cd->flush_time + 1;
              then =3D now;
       }

       cd->flush_time =3D then;
--------------------------------------------------------------------------

Best Regards,
Alan Wang

