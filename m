From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [BUG] 2.6.23-rc5 kernel BUG at fs/nfs/nfs4xdr.c:945
Date: Mon, 10 Sep 2007 23:03:48 +0200
Message-ID: <1189458228.6634.4.camel@heimdal.trondhjem.org>
References: <46E121B8.4080105@linux.vnet.ibm.com>
	 <6bffcb0e0709071656o6881fa17y61818a9733293a4c@mail.gmail.com>
	 <1189289549.13713.4.camel@localhost.localdomain>
	 <46E4FC2F.6040105@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, ffilz@us.ibm.com,
	Poornima <bnpoorni@in.ibm.com>
To: suzuki <suzuki@in.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761293AbXIJVEc@vger.kernel.org>
In-Reply-To: <46E4FC2F.6040105@in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2007-09-10 at 13:41 +0530, suzuki wrote:
> Hi
> 
> I have been trying to debug this issue from my side and could find the 
> following.
> 
> The pathconf() request gets a reply with :
> 
> pathinfo.max_namelen = (unsiged int) -1
> pathinfo.max_link    = 255
> 
> Is this really an expected answer from a server for a proper connection 
> ( for mount requests on an exported dir) ? Is there something that needs 
> to be fixed at server side ?

I assume that this is with my patch applied? Yes: as long as the kernel
sets NAME_MAX to 255, then the above is expected behaviour.

Trond
