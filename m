Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31832 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783Ab2EJQpM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 12:45:12 -0400
Date: Thu, 10 May 2012 09:45:10 -0700
From: "Haynes, Tom" <thomas@netapp.com>
To: Mahmoud TAZI <ma.tazi@hotmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] problem with nfsv4_getfacl
Message-ID: <20120510164509.GB32299@netapp.com>
References: <SNT128-W8F875E866DAA64DF4476EEB160@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <SNT128-W8F875E866DAA64DF4476EEB160@phx.gbl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2012 at 02:28:12PM +0100, Mahmoud TAZI wrote:
> 
> hello,
> 
> I have problems when implementing the nfsv4_ACL,
> 
> I have a NetAPP server where we share two files system (UNIX,Windows), i can mount the unix file ystem with NFSv4 (mount -t nfs4 -o acl server:/ /mnt) from suse entreprise 11 SP1, but when i try to get acl i have the errors bellow
> 
> nfs4_getfacl test
> Failed getxattr operation: Input/output error
> 
> i tried from an AIX server and Solaris server, and i can get and set the nfsv4 ACLs
> 
> In SUSE i also insall the nfs4-acl-tools package 
> 
>  		 	   		  

Hi Mahmoud,

Wrong list - this is not for help on implementations. In this case, you want to try linux-nfs@vger.kernel.org

I've pushed you there and BCC'ed the NFSv4 WG alias.

Enjoy,

-- 
thomas@netapp.com, ex-cfb
