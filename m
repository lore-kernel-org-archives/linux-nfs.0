Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:45566 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821Ab2DWTG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 15:06:29 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 23 Apr 2012 13:06:28 -0600
Date: Mon, 23 Apr 2012 14:06:22 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        miklos@szeredi.hu, viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com, bfields@fieldses.org,
        trond.myklebust@fys.uio.no, rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
Message-ID: <20120423190622.GA1175@us.ibm.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
 <1334749927-26138-1-git-send-email-jlayton@redhat.com>
 <20120420104055.511e15bc@tlielax.poochiereds.net>
 <4F91C49D.8070908@RedHat.com>
 <20120420171300.326d6e36@corrin.poochiereds.net>
 <4F956D5C.5050801@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F956D5C.5050801@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson [SteveD@redhat.com] wrote:
> > Returning ESTALERETRY would be registering for it in a way and it is
> > somewhat cleaner than having to go all the way back up to the fstype to
> > figure out whether you want to retry it or not.
> How would legacy apps handle this new errno, esp if they have logic
> to take care of ESTALE errors?
> 
> steved.

As I understand, there is no new errno for the apps. This new
ESTALERETRY is produced and consumed by kernel only.

