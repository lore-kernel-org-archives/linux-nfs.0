Return-Path: <pgp@psu.edu>
Message-ID: <4C5317B9.4030806@psu.edu>
Date: Fri, 30 Jul 2010 14:19:37 -0400
From: Phil Pishioneri <pgp@psu.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Volker.Lendecke@SerNet.DE, Jeremy Allison <jra@samba.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
 file stats available [ver #6]
References: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>	 <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>	 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>	 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>	 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>	 <20100722162712.GB10352@jeremy-laptop>	 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>	 <1279817930.3621.14.camel@heimdal.trondhjem.org>	 <20100722180204.GA32008@samba1>  <E1Oc08W-00CZuz-Ns@intern.SerNet.DE>	 <1279825160.3621.71.camel@heimdal.trondhjem.org> <4C5311F4.2050100@psu.edu> <1280513506.12852.22.camel@heimdal.trondhjem.org>
In-Reply-To: <1280513506.12852.22.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

  On 7/30/10 2:11 PM, Trond Myklebust wrote:
> Your Mac has a perfectly functional CIFS client,

It didn't, at one point. Some version of Mac OS X would cause a client 
kernel crash when unmounting the CIFS share. I think it's been fixed, 
but we had to have some OS X clients switch to NFS because of it.

-Phil
