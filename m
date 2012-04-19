Return-Path: linux-nfs-owner@vger.kernel.org
Received: from toast.topped-with-meat.com ([204.197.218.159]:36041 "EHLO
	topped-with-meat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485Ab2DSXGC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 19:06:02 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Roland McGrath <roland@hack.frob.com>
To: Paul Eggert <eggert@cs.ucla.edu>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
In-Reply-To: Paul Eggert's message of  Thursday, 19 April 2012 14:51:18 -0700 <4F9088D6.9020203@cs.ucla.edu>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<20120419163238.61D382C0DF@topped-with-meat.com>
	<4F9088D6.9020203@cs.ucla.edu>
Message-Id: <20120419230556.A80392C0AF@topped-with-meat.com>
Date: Thu, 19 Apr 2012 16:05:56 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

statx seems like a better family of names.  I also think it's worthwhile to
see if the interface can be made to more closely match the AIX precedent.


Thanks,
Roland
