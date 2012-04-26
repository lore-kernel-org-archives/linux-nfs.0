Return-Path: linux-nfs-owner@vger.kernel.org
Received: from toast.topped-with-meat.com ([204.197.218.159]:53902 "EHLO
	topped-with-meat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759385Ab2DZWCp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 18:02:45 -0400
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
In-Reply-To: David Howells's message of  Thursday, 26 April 2012 22:54:41 +0100 <9931.1335477281@redhat.com>
References: <20120426182524.E5ADF2C0EC@topped-with-meat.com>
	<20120419163238.61D382C0DF@topped-with-meat.com>
	<20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<19184.1335448455@redhat.com>
	<9931.1335477281@redhat.com>
Message-Id: <20120426220242.53FC22C0D3@topped-with-meat.com>
Date: Thu, 26 Apr 2012 15:02:42 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> fileinfoat() perhaps?  I think stat*at() is better, though, as people are
> used to the stat function family.

Names like that were all I had thought of when I said I hadn't thought of
any good ones. ;-)
