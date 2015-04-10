Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e19.ny.us.ibm.com ([129.33.205.209]:35194 "EHLO
	e19.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038AbbDJDJs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2015 23:09:48 -0400
Received: from /spool/local
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 9 Apr 2015 23:09:47 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 163CFC9003E
	for <linux-nfs@vger.kernel.org>; Thu,  9 Apr 2015 23:00:54 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3A39ipB17105060
	for <linux-nfs@vger.kernel.org>; Fri, 10 Apr 2015 03:09:44 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3A39iKs011053
	for <linux-nfs@vger.kernel.org>; Thu, 9 Apr 2015 23:09:44 -0400
Date: Thu, 9 Apr 2015 22:09:41 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Gregory Boyce <gregory.boyce@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems mounting via UDP from a netapp with multiple interfaces
Message-ID: <20150410030941.GA1960@us.ibm.com>
References: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Gregory Boyce [gregory.boyce@gmail.com] wrote:
> Folks,
> 
> I've been encountering a problem with NFS clients attempting to mount
> from a netapp via UDP where the netapp is responding on the wrong
> interface.  On some of our older systems, this mount worked properly,
> while on newer systems nfs-utils ends up failing the mount.  Mounting
> via TCP works fine.
> 
> It appears that there has been various related discussions over the
> years, and a relevant Redhat bug opened back in 2006:
> 
> http://article.gmane.org/gmane.linux.nfs/22778/match=connect+udp
> https://bugzilla.redhat.com/show_bug.cgi?id=208244
> 
> Is there a general recommendation for people in this sort of
> situation?  I'm assuming the code is currently using connected UDP
> sockets (I'm more of a sysadmin than a developer).  Is there an option
> I'm missing to disable this?  Otherwise does anyone know of a patch to
> change the behavior?

Just an FYI, I encountered this issue on user space ganesha NFS server.
Kernel NFS server uses PKTINFO to account for this. I fixed ganesha NFS
server as well to do the same!

Regards, Malahal.

