From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: Re: [2.6.31] NFS4ERR_GRACE unhandled...
Date: Sun, 4 Oct 2009 23:22:38 +0100
Message-ID: <6278d2220910041522g47a96070nd948f3b61ff9dc7b@mail.gmail.com>
References: <6278d2220909261114g2e1529dfn4961d450460b00dc@mail.gmail.com>
	 <1254161800.3308.1.camel@heimdal.trondhjem.org>
	 <6278d2220910030859s1fb8d200n7d032e2c1b235ce@mail.gmail.com>
	 <1254694252.30515.63.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:42995 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053AbZJDWXP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Oct 2009 18:23:15 -0400
Received: by ewy7 with SMTP id 7so2995418ewy.17
        for <linux-nfs@vger.kernel.org>; Sun, 04 Oct 2009 15:22:38 -0700 (PDT)
In-Reply-To: <1254694252.30515.63.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 4, 2009 at 11:10 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Sat, 2009-10-03 at 16:59 +0100, Daniel J Blueman wrote:
>> Hi Trond,
>>
>> On Mon, Sep 28, 2009 at 7:16 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Sat, 2009-09-26 at 19:14 +0100, Daniel J Blueman wrote:
>> >> Hi Trond,
>> >>
>> >> After rebooting my 2.6.31 NFS4 server, I see a list of NFS kernel
>> >> errors [1] on the 2.6.31 client corresponding to NFS4ERR_GRACE, s=
o
>> >> lock or file state recovery failed. Is this expected noting that =
I
>> >> have an internal firewall allowing incoming TCP port 2049 on the
>> >> server, and no firewall on the client, however I can't see how it=
 can
>> >> thus be callback related?
>> >
>> > No. It looks as if your server rebooted while the client was recov=
ering
>> > an expired lease.
>> >
>> > The following patch should prevent future occurrences of this bug.=
=2E.
>> >
>> > Cheers
>> > =A0Trond
>> > ------------------------------------------------------------------
>> > NFSv4: Handle NFS4ERR_GRACE when recovering an expired lease.
>> >
>> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
>> >
>> > If our lease expires, and the server subsequently reboot, we need =
to be
>> > able to handle the case where the server refuses to let us recover=
 state,
>> > because it is in the grace period.
>>
>> On the client, I didn't see the error messages with this patch,
>> however I did see firefox (via sqlite) continue to hang [1] (after
>> other processes continued), and an unusual level of activity with
>> rpciod/0 and rpciod/1 kernel threads. Other NFS-related kernel threa=
d
>> state is given.
>
> What are your mount options?

$ grep nfs /proc/mounts
x1:/ /net nfs4 rw,relatime,vers=3D4,rsize=3D262144,wsize=3D262144,namle=
n=3D255,hard,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clientaddr=3D=
192.168.10.2,addr=3D192.168.10.250
0 0

All procfs settings are default; let me know if anything else will
help and thanks for taking a look!

Daniel
--=20
Daniel J Blueman
