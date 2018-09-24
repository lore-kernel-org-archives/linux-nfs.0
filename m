Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47152 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725986AbeIYEDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Sep 2018 00:03:12 -0400
Date: Mon, 24 Sep 2018 17:58:54 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: =?utf-8?B?SsOka2VsLA==?= Guido <G.Jaekel@dnb.de>
Cc: 'Jeff Layton' <jlayton@kernel.org>,
        "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: Re: NFS3 subsystem hung, Kernel alive
Message-ID: <20180924215854.GA9559@fieldses.org>
References: <01105607924f4f9ea0dbf14f9ae45268@dnb.de>
 <74259d8dda7b4753b0d49e7e60c293e5@dnb.de>
 <d4da0e3ad43b4a4da7a6a6d2c0615939@dnb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <d4da0e3ad43b4a4da7a6a6d2c0615939@dnb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 20, 2018 at 10:52:17AM +0000, Jäkel, Guido wrote:
> Hi all,
> 
> Today at about "the event time" production keeps running but I discover that one of the hosts in the Test stage (bladerunner10) become very "stuttering" to react on commands.
> 
> From  https://utcc.utoronto.ca/~cks/space/blog/linux/NFSMountstatsXprt  I got some information about. And I started to
> 
> 	watch -n 1 "sed -n '/^device .* on \/ with/,/^$/ p'  /proc/self/mountstats"
> 
> on the hosts to watch the root mount. On  bladerunner10  I notice a very high value of the 8th field of xprt ('bad XIDs'), which is identical to the difference between filed 6 and 7 (TX-RX). Does that mean, that there were a high number of bad answers to questions? Or is this the number of replies that are out of time? 

I don't know what you mean by "filed 6 and 7".  Oh, wait, I guess you're
talking about the 6th and 7th fileds of the "xprt" line in mountstats.

bad_xids means the client got a response but couldn't find a matching
reply.  I'm not sure why that would happen--maybe a response came after
the client gave up waiting for it?

--b.

> 
> If I watch TX-RX-BAD, this is near zero on all hosts. But on bladerunner10, it sometime rises to enormous values (>100000) and in this moment, all File-IO is frozen - E.g. I don't get a new prompt if I simply hit enter on an bash command line.
> 
> 
> 
> device 10.69.63.196:/02/q/diskless/roots/bladerunner10 mounted on / with fstype nfs statvers=1.1
>         opts:   rw,vers=3,rsize=1024,wsize=1024,namlen=255,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.69.63.196,mountvers=3,mountport=0,mountproto=tcp,local_lock=all
>         age:    9939702
>         caps:   caps=0x3fc7,wtmult=512,dtsize=1024,bsize=0,namlen=255
>         sec:    flavor=1,pseudoflavor=1
>         events: 269343924 134739087308 20734 140915 232195524 79262 134886538148 21804722 104 16067 0 293341786 222190 75356 177067969 35796 2826 231908027 0 411 21783902 199 0 0 0 0 0 
>         bytes:  128654830696 20320953759 0 0 219517679 20415228955 63772 5008821 
>         RPC iostats version: 1.0  p/v: 100003/3 (nfs)
>         xprt:   tcp 837 1 1 0 0 21448220350 21448165066 55284 576287654630121 0 34712 845220323041 514256914035
>         per-op statistics
>                 NULL: 0 0 0 0 0 0 0 0
>              GETATTR: 269343899 269343899 0 36809071916 30166513552 3034498 71578350 78080492
>              SETATTR: 75721 75721 0 15972628 10903824 1855 70284 73720
>               LOOKUP: 80296 80296 0 15825484 18814360 7312 135951 144678
>               ACCESS: 39274 39274 0 7048052 4712880 4241 26485 31274
>             READLINK: 995 995 0 170796 139564 72 479 567
>                 READ: 223945 223945 0 40327228 248198116 130225 1437810 1583172
>                WRITE: 19958985 19958985 0 24406783848 3193437600 167421458404 27086586679 194511012992
>               CREATE: 5281 5281 0 1126060 1542052 132 21698 21989
>                MKDIR: 127 127 0 29160 36740 10 12307 12321
>              SYMLINK: 3 3 0 716 876 0 1 1
>                MKNOD: 3 3 0 636 876 0 2 2
>               REMOVE: 3400 3400 0 663604 489600 52 12164 12312
>                RMDIR: 122 122 0 24624 17520 15 463 483
>               RENAME: 2074 2074 0 491352 539240 67 11433 11529
>                 LINK: 0 0 0 0 0 0 0 0
>              READDIR: 31882 31882 0 6376400 32311036 2707 64806 68379
>          READDIRPLUS: 273882 273882 0 55807876 140884360 14257 509826 530894
>               FSSTAT: 538 538 0 95212 90384 61 445 519
>               FSINFO: 2 2 0 272 328 0 0 0
>             PATHCONF: 1 1 0 136 140 0 0 0
>               COMMIT: 0 0 0 0 0 0 0 0
> 
> 
