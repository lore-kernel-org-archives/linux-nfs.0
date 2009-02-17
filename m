Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54471 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbZBQVrI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 16:47:08 -0500
Date: Tue, 17 Feb 2009 16:47:05 -0500
To: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: getattr miss
Message-ID: <20090217214705.GA13732@fieldses.org>
References: <499B217A.2010504@uvm.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <499B217A.2010504@uvm.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 17, 2009 at 03:43:38PM -0500, Benjamin Coddington wrote:
> Forgive me for what may be an obvious question.  In the middle of  
> tracking down NFS4ERR_RESOURCE storms from an AIX server to linux  
> clients on three busy webservers, I noticed that our linux client  
> performs a compound OPEN,GETATTR for every read of a file even if the  
> reads are well within the attribute cache timeout.  Adding nocto doesn't  
> seem to change this behavior -- and for apache looking up numerous  
> .htaccess files it would be great to avoid the trip to the server to  
> revalidate attributes if we're within the timeout.

The NFSv4 client has to send an open to the server on each local open.

The one way to avoid this is with delegations.  I don't know what sort
of delegation support the AIX server has.  Probably at least some.

NFSv4.0 delegations require the server to open a separate connection
back to the client for recalls; a NAT or firewall could be getting in
the way of that.

--b.

>
> So the simple question: is this expected?  I'd like to minimize  
> consecutive GETATTR calls, if possible, and get the most from VFS cache.
>
> I've got some ridiculous timeouts set up at this point:
>
> barasinga.uvm.edu:/ on /fs/barasinga type nfs4  
> rw,sec=krb5,nocto,hard,intr,actimeo=3600,addr=132.198.101.73
>
> Ben
> -- 
> Benjamin Coddington
> Systems Architecture and Administration
> Enterprise Technology Services
> University of Vermont
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
