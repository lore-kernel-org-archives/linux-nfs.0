Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783Ab2DZNy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 09:54:56 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120419163238.61D382C0DF@topped-with-meat.com>
References: <20120419163238.61D382C0DF@topped-with-meat.com> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
To: Roland McGrath <roland@hack.frob.com>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
Date: Thu, 26 Apr 2012 14:54:15 +0100
Message-ID: <19184.1335448455@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Roland McGrath <roland@hack.frob.com> wrote:

> I have no comment on the functionality.  But "xstat" is probably a poor
> choice of name.  There is precedent for that function name with different
> meaning in the userland APIs.  (It's a moderately useless meaning inherited
> from SVR4, but regardless overloading a name previously used is unwise.)

I've no particular attachment to the name 'xstat'.  If you'd prefer 'statx' I
could go for that.

David
