Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28263 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752441Ab1KOGeD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Nov 2011 01:34:03 -0500
Message-ID: <1321338825.8267.2.camel@lade.trondhjem.org>
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Christoph Hellwig <hch@infradead.org>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Date: Tue, 15 Nov 2011 08:33:45 +0200
In-Reply-To: <20111114080745.57083bfe@notabene.brown>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	 <1321056809.8733.2.camel@lade.trondhjem.org>
	 <20111112144953.GA3740@infradead.org>
	 <20111113145400.6c7a9be3@notabene.brown>
	 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
	 <20111113163632.GA28574@fieldses.org>
	 <20111114080745.57083bfe@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-11-14 at 08:07 +1100, NeilBrown wrote:

> If a server has objects that are never renamed, it can easily use volatile
> file handles.
> If a server has objects which can be renamed and wants to use volatile file
> handles, then if such an object is open and is about to be renamed, it must
> first log to stable storage some mapping to allow it to access the file from
> the old volatile file handle.  And of course it cannot allow renames during
> the grace period, but I think we already have that.
> Also, if the VFH is such that it will be  lost on a reboot, the server must
> log it to stable storage before allowing an open.

BTW: If the namespace is stable, then the server can easily implement
permanent filehandles. Use a hash of the pathname as the filehandle, and
set up a hidden directory ('/.filehandles') containing symlinks that map
said hash back to the correct pathname. No need for volatile
filehandles.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

