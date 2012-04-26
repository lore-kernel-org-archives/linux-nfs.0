Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755008Ab2DZVzZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 17:55:25 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120426182524.E5ADF2C0EC@topped-with-meat.com>
References: <20120426182524.E5ADF2C0EC@topped-with-meat.com> <20120419163238.61D382C0DF@topped-with-meat.com> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <19184.1335448455@redhat.com>
To: Roland McGrath <roland@hack.frob.com>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
Date: Thu, 26 Apr 2012 22:54:41 +0100
Message-ID: <9931.1335477281@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Roland McGrath <roland@hack.frob.com> wrote:

> > I've no particular attachment to the name 'xstat'.  If you'd prefer
> > 'statx' I could go for that.
> 
> I prefer something other than xstat and statx(at) seems acceptable enough.
> What I'd really prefer is a name that is less meaninglessly arcane,
> but I haven't thought of any good ones.

fileinfoat() perhaps?  I think stat*at() is better, though, as people are used
to the stat function family.

David
