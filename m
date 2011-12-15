Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37417 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257Ab1LORZk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 12:25:40 -0500
Message-ID: <1323969923.14317.31.camel@lade.trondhjem.org>
Subject: Re: copy offload support in Linux - new system call needed?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Ric Wheeler <ricwheeler@gmail.com>
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-scsi@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 15 Dec 2011 12:25:23 -0500
In-Reply-To: <4EEA2BF7.5030107@gmail.com>
References: <4EE8F75F.6070800@gmail.com>
	  <20111214192739.GN2203@ZenIV.linux.org.uk> <4EE8FC2E.3010207@gmail.com>
	  <20111214222723.GD7623@fieldses.org>
	  <1323961140.14317.2.camel@lade.trondhjem.org>
	  <D3F292ADF945FB49B35E96C94C2061B91516E391@nsmail.netscout.com>
	  <1323965498.14317.13.camel@lade.trondhjem.org>
	  <D3F292ADF945FB49B35E96C94C2061B91516E3FC@nsmail.netscout.com>
	 <1323968015.14317.28.camel@lade.trondhjem.org> <4EEA2BF7.5030107@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-12-15 at 12:18 -0500, Ric Wheeler wrote: 
> What I would like to see is a way to make sure that we can interrupt any long 
> running command & also make sure that our timeouts (for SCSI specifically) are 
> not too aggressive.

The draft NFSv4.2 protocol contains features to make interruption
possible, so as far as the NFS client is concerned, that should be
doable. I can't answer for CIFS or SCSI...

Cheers
  Trond 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

