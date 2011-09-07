Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54055 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754244Ab1IGGJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Sep 2011 02:09:45 -0400
Date: Wed, 7 Sep 2011 16:09:33 +1000
From: NeilBrown <neilb@suse.de>
To: Richard Smits <R.Smits@tudelft.nl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: rpc.mountd switch not working
Message-ID: <20110907160933.2a26ef3a@notabene.brown>
In-Reply-To: <4E64C8A0.6020806@tudelft.nl>
References: <4E64C8A0.6020806@tudelft.nl>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 05 Sep 2011 15:03:28 +0200 Richard Smits <R.Smits@tudelft.nl> wrote:

> Hello,
> 
> I have a question about the use of the following switch with rpc.mountd.
> 
> -g  or  --manage-gids
> 
> It has come to my attention that the use of this switch is not working 
> well in Redhat v6. When I have a user who has a large group membership, 
> the following errors appear, and the "cd" command hangs.
> 
> Sep  5 14:50:04 srv043 rpc.mountd[2563]: qword_eol: fflush failed: errno 
> 22 (Invalid argument)
> 
> Process :
> 
> root      2563     1  0 14:44 ?        00:00:00 rpc.mountd -g
> 
> The use of 60 groups is working well, but we have some users with more 
> than 100 groups, and those fails. For uid mapping we use Winbind.
> 
> /etc/exports :
> 
> /export  server.company.com(rw,no_subtree_check,no_root_squash)
> 
> Client fstab :
> 
> server.company.com:/export   /data           nfs 
> nolock,defaults,user        1 2
> 
> Can anyone tell me what this error means ?

Probably means that the redhat package is missing upstream commit
9274e94db85bac04e170414cb8e0f4be271cde90
(which is from April this year, so not unlikely).

http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commitdiff;h=5604b35a61e22930873ffc4e9971002f578e7978

NeilBrown


> 
> Greetings .. Richard Smits
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

