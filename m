Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.cs.ucla.edu ([131.179.128.62]:40162 "EHLO smtp.cs.ucla.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932708Ab2DSV7N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Apr 2012 17:59:13 -0400
Message-ID: <4F9088D6.9020203@cs.ucla.edu>
Date: Thu, 19 Apr 2012 14:51:18 -0700
From: Paul Eggert <eggert@cs.ucla.edu>
MIME-Version: 1.0
To: Roland McGrath <roland@hack.frob.com>
CC: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <20120419163238.61D382C0DF@topped-with-meat.com>
In-Reply-To: <20120419163238.61D382C0DF@topped-with-meat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/19/2012 09:32 AM, Roland McGrath wrote:
> I have no comment on the functionality.  But "xstat" is probably a poor
> choice of name. 

In AIX 7.1 the (similar) function is called statxat instead of xstat.
The API isn't exactly the same, but it's the same basic idea.
Might be worth looking at, not merely to see whether the API
should be the same, but also to borrow good ideas even if not.

http://pic.dhe.ibm.com/infocenter/aix/v7r1/topic/com.ibm.aix.basetechref/doc/basetrf2/statx.htm
