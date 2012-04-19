Return-Path: linux-nfs-owner@vger.kernel.org
Received: from toast.topped-with-meat.com ([204.197.218.159]:56450 "EHLO
	topped-with-meat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024Ab2DSQkn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 12:40:43 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Roland McGrath <roland@hack.frob.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
In-Reply-To: David Howells's message of  Thursday, 19 April 2012 15:05:58 +0100 <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
Message-Id: <20120419163238.61D382C0DF@topped-with-meat.com>
Date: Thu, 19 Apr 2012 09:32:38 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have no comment on the functionality.  But "xstat" is probably a poor
choice of name.  There is precedent for that function name with different
meaning in the userland APIs.  (It's a moderately useless meaning inherited
from SVR4, but regardless overloading a name previously used is unwise.)


Thanks,
Roland
