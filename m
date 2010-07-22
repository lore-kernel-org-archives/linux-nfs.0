Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754432Ab0GVQHc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 12:07:32 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <alpine.LSU.2.01.1007221740570.12308@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221740570.12308@obet.zrqbmnf.qr> <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk> <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE> <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com> 
To: Jan Engelhardt <jengelh@medozas.de>
Cc: dhowells@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Date: Thu, 22 Jul 2010 17:06:52 +0100
Message-ID: <20728.1279814812@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Jan Engelhardt <jengelh@medozas.de> wrote:

> There just is no way currently to store creation times.

What do you mean?  Ext4 and BtrFS can both do so; it's just that there's no
user interface to it.

David

