From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH] Stop call_decode() from ignorning RPC header errrors
Date: 20 Aug 2003 12:09:17 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <shsekzgxi1u.fsf@charged.uio.no>
References: <3F43B13C.5010403@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>,
	acl-devel@bestbits.at
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
In-Reply-To: <3F43B13C.5010403@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Steve Dickson <SteveD@redhat.com> writes:

     > This patch stop call_decode() from ignoring errors that are
     > found while parsing the RPC header. I turns out the nfs acls
     > routines need these error codes to do the right thing...

Duh... Yeah... That is broken in 2.4.22-rc2, and it's not only the NFS
ACLs that will break.

Marcelo, could you please apply?

Cheers,
  Trond
