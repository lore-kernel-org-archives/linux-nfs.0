From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Re: [PATCH v2] reduce NFS stack usage
Date: 25 Sep 2003 12:37:25 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <shsk77w3bii.fsf@charged.uio.no>
References: <mailman.1064420466.30286.linux-kernel2news@redhat.com>
	<3F7335B4.1070002@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, nfs@lists.sourceforge.net,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3F7335B4.1070002@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Steve Dickson <SteveD@redhat.com> writes:

     > Also, not like there much choice in matter, but I wonder what
     > type of performance hit (if any) there will be by making these
     > routines call kmalloc()... lookups and readdirs are pretty
     > popular ops...

There are always alternatives...

If really this is a problem, how about slabifying the structs
nfs_fattr and/or nfs_fh?

Also, since nfs_entry is only large due to the fh and fattr fields
which are unused unless you have READDIRPLUS (in which case they are
converted to pointers anyhow), how about kicking them out of
nfs_entry altogether?

Cheers,
  Trond
