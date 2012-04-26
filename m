Return-Path: linux-nfs-owner@vger.kernel.org
Received: from toast.topped-with-meat.com ([204.197.218.159]:50138 "EHLO
	topped-with-meat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168Ab2DZSWG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 14:22:06 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Roland McGrath <roland@hack.frob.com>
To: David Howells <dhowells@redhat.com>
Cc: Paul Eggert <eggert@cs.ucla.edu>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
In-Reply-To: David Howells's message of  Thursday, 26 April 2012 15:16:00 +0100 <20173.1335449760@redhat.com>
References: <20120419230556.A80392C0AF@topped-with-meat.com>
	<20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<20120419163238.61D382C0DF@topped-with-meat.com>
	<4F9088D6.9020203@cs.ucla.edu>
	<20173.1335449760@redhat.com>
Message-Id: <20120426182202.9B2442C0EA@topped-with-meat.com>
Date: Thu, 26 Apr 2012 11:22:02 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Roland McGrath <roland@hack.frob.com> wrote:
> 
> > statx seems like a better family of names.  I also think it's worthwhile to
> > see if the interface can be made to more closely match the AIX precedent.
> 
> I'm not sure we can make Linux xstat (or whatever) match AIX statxat() very
> closely, at least from a syscall interface point of view.  

OK.  It was just worth a look.


Thanks,
Roland
