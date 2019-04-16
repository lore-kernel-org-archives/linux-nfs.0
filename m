Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 575FCC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 20:46:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 206072075B
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 20:46:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728000AbfDPUqF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 16:46:05 -0400
Received: from fieldses.org ([173.255.197.46]:39552 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727136AbfDPUqF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Apr 2019 16:46:05 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 218493EB; Tue, 16 Apr 2019 16:46:05 -0400 (EDT)
Date:   Tue, 16 Apr 2019 16:46:05 -0400
To:     Bruno Santos <bacmsantos@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: nfs v4.2 leaking file descriptors
Message-ID: <20190416204605.GB6662@fieldses.org>
References: <CANUurQovk32SFS_jDMpgmM-CktFJGF1yd5Fv_JOW2BFe4DsJPg@mail.gmail.com>
 <CANUurQr77yK5q6cKc3oFEeLE0ZdyEDDHmyiWCAWsWqVjfGGgjw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANUurQr77yK5q6cKc3oFEeLE0ZdyEDDHmyiWCAWsWqVjfGGgjw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Apr 15, 2019 at 06:00:56PM +0100, Bruno Santos wrote:
> We have a debian stretch HPC cluster(#1 SMP Debian 4.9.130-2
> (2018-10-27)). One of the machines mounts a couple of drives from a
> Dell compellent system and shares it across a 10GB network to 4
> different machines.
> 
> We had the nfs server crashing a few weeks ago because the file-max
> limit had been reached. At the time we increased the number of file
> handles it can handle and been monitoring since. We have noticed that
> the number of entries on that machine keeps increasing though and
> despite our best efforts we have been unable identify the cause.
> Anything I can find related to this is from a well known bug in 2011
> and nothing afterwards. We are assuming this is caused but a leak of
> file handles on the nfs side but not sure.
> 
> Does anyone has anyway of figuring out what is causing this? Output
> from the file-ne, lsof, etc is below.

Off the top of my head, the only idea I have is to try watching

	grep nfsd4 /proc/slabinfo

and see if any of those objects are also leaking.

--b.

> 
> Thank you very much for any help you can provide.
> 
> Best regards,
> Bruno Santos
> 
> :~# while :;do echo "$(date): $(cat /proc/sys/fs/file-nr)";sleep
> 30;done
> Mon 15 Apr 17:23:11 BST 2019: 2466176   0       4927726
> Mon 15 Apr 17:23:41 BST 2019: 2466176   0       4927726
> Mon 15 Apr 17:24:11 BST 2019: 2466336   0       4927726
> Mon 15 Apr 17:24:41 BST 2019: 2466240   0       4927726
> Mon 15 Apr 17:25:11 BST 2019: 2466560   0       4927726
> Mon 15 Apr 17:25:41 BST 2019: 2466336   0       4927726
> Mon 15 Apr 17:26:11 BST 2019: 2466400   0       4927726
> Mon 15 Apr 17:26:41 BST 2019: 2466432   0       4927726
> Mon 15 Apr 17:27:11 BST 2019: 2466688   0       4927726
> Mon 15 Apr 17:27:41 BST 2019: 2466624   0       4927726
> Mon 15 Apr 17:28:11 BST 2019: 2466784   0       4927726
> Mon 15 Apr 17:28:41 BST 2019: 2466688   0       4927726
> Mon 15 Apr 17:29:11 BST 2019: 2466816   0       4927726
> Mon 15 Apr 17:29:42 BST 2019: 2466752   0       4927726
> Mon 15 Apr 17:30:12 BST 2019: 2467072   0       4927726
> Mon 15 Apr 17:30:42 BST 2019: 2466880   0       4927726
> 
> ~# lsof|wc -l
> 3428
