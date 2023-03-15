Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1815DC61DA4
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Mar 2023 22:04:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230361AbjCOWEh convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 15 Mar 2023 18:04:37 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43412 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230322AbjCOWEg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Mar 2023 18:04:36 -0400
Received: from lithops.sigma-star.at (lithops.sigma-star.at [195.201.40.130])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CDFEE40DC
        for <linux-nfs@vger.kernel.org>; Wed, 15 Mar 2023 15:04:33 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id F08B261989E6;
        Wed, 15 Mar 2023 23:04:30 +0100 (CET)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10032)
        with ESMTP id XVog1uZQtGyi; Wed, 15 Mar 2023 23:04:30 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id A055261989EA;
        Wed, 15 Mar 2023 23:04:30 +0100 (CET)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10026)
        with ESMTP id AGtvM36tc7lN; Wed, 15 Mar 2023 23:04:30 +0100 (CET)
Received: from lithops.sigma-star.at (lithops.sigma-star.at [195.201.40.130])
        by lithops.sigma-star.at (Postfix) with ESMTP id 8526A61989E6;
        Wed, 15 Mar 2023 23:04:30 +0100 (CET)
Date:   Wed, 15 Mar 2023 23:04:30 +0100 (CET)
From:   Richard Weinberger <richard@nod.at>
To:     Steve Dickson <steved@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>,
        trond myklebust <trond.myklebust@hammerspace.com>,
        chris chilvers <chris.chilvers@appsbroker.com>
Message-ID: <1335921550.247985.1678917870352.JavaMail.zimbra@nod.at>
In-Reply-To: <404384146.237438.1678639902506.JavaMail.zimbra@nod.at>
References: <1497292229.221220.1678287959937.JavaMail.zimbra@nod.at> <655a8ee6-dd94-effd-738a-9ce8db8ebed7@redhat.com> <156604342.233758.1678553565027.JavaMail.zimbra@nod.at> <31643f88-26ec-515c-d1d6-fad951248a8c@redhat.com> <1826031117.236924.1678628160815.JavaMail.zimbra@nod.at> <ecfe32fc-f547-ca7f-dc07-018af4d23f39@redhat.com> <404384146.237438.1678639902506.JavaMail.zimbra@nod.at>
Subject: Re: mountd: Possible bug in next_mnt()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
X-Originating-IP: [195.201.40.130]
X-Mailer: Zimbra 8.8.12_GA_3807 (ZimbraWebClient - FF97 (Linux)/8.8.12_GA_3809)
Thread-Topic: mountd: Possible bug in next_mnt()
Thread-Index: wocOLM+GHMEzj1fvYhC4rhW6Kianr2enxbB6
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

----- Ursprüngliche Mail -----
>> I'm still trying to reproduce problem... I have
>> 
>> /etc/nfs.conf: rootdir=/export
>> 
>> /etc/exports:
>> /home *(rw,sec=sys:krb5:krb5i:krb5p)
>> /tmp *(rw,fsid=666,all_squash)
>> / *(rw,fsid=root,all_squash)
>> 
>> I'm not seeing the problem... Where does the crossmount come in?
> 
> Chris reported the problem to me while he was testing my re-export/crossmount
> patches.
> I can try reproducing without re-exporting later.

Finally I found some cycles to reproduce without my re-exporting setup.

1. /etc/exports contains:
/       *(rw,crossmnt,no_subtree_check,fsid=root)

2. /etc/nfs.conf contains:

[exports]
 rootdir=/nfs_srv
 
3. Mounts:

/root/fs1.ext4 on /nfs_srv type ext4 (rw,relatime)
/root/fs2.ext4 on /nfs_srv/fs2 type ext4 (rw,relatime)

4. On the client:

# ls /nfs_client/fs2
ls: cannot open directory '/nfs_client/fs2': Stale file handle

I'll send a proper patch ASAP.
next_mnt() has to deal with "/" too.

Thanks,
//richard
