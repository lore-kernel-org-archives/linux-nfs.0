From: utz lehmann <lkml123-4es5y7D8suKELgA04lAiVw@public.gmane.org>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Date: Sun, 01 Aug 2010 18:18:44 +0200
Message-ID: <1280679524.2464.49.camel@segv.aura.of.mankind>
References: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	 <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
	 <AANLkTimwIq0pBhCeOjOVjB0y  <1280603032.3125.24.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andreas Dilger <adilger@dilger.ca>, Phil Pishioneri <pgp@psu.edu>,
	Volker.Lendecke@SerNet.DE, Jeremy Allison <jra@samba.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Howells <dhowells@redhat.com>,
	Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>,
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-cifs-owner@vger.kernel.org>
In-Reply-To: <1280603032.3125.24.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-cifs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2010-07-31 at 15:03 -0400, Trond Myklebust wrote:
> Sigh... So please explain how it would be useful to export that
> particular filesystem through _both_ CIFS and NFS?
> 
> My point was that in most circumstances you want to export either
> through CIFS or through NFS, but very rarely both.

It common in heterogeneous networks. Linux clients uses NFS. Windows
clients uses CIFS. Both working on the same data.

And even the better ones of these small SATA NAS boxes support NFS and
CIFS for the same volumes.

utz
