Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58359 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756112Ab0JUSCE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 14:02:04 -0400
Date: Thu, 21 Oct 2010 14:01:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        =?utf-8?Q?Cl=C3=A1udio?= Martins <ctpm@ist.utl.pt>,
        Ian Munsie <imunsie@au1.ibm.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Scott Romanowski <romansc@us.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NFS sillyrename side effect
Message-ID: <20101021180150.GB10192@fieldses.org>
References: <1287362142-sup-777@au1.ibm.com>
 <20101018101059.574b715a@corrin.poochiereds.net>
 <20101018154811.768baeb5.ctpm@ist.utl.pt>
 <20101018155344.6e50dbb9.ctpm@ist.utl.pt>
 <20101018110138.5f5001eb@corrin.poochiereds.net>
 <20101018171015.GB3744@fieldses.org>
 <4CBD3D4E.5080305@panasas.com>
 <1287495168.2969.9.camel@heimdal.trondhjem.org>
 <4CC07D54.7070204@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CC07D54.7070204@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 21, 2010 at 07:50:12PM +0200, Benny Halevy wrote:
> On 2010-10-19 15:32, Trond Myklebust wrote:
> > This would require access, directory create, and delete permissions for
> > the directory '<mountpoint>/', which is not always a given.
> 
> Correct. But that's pretty easy to probe :)
>
> > Besides, what if the server reboots, and my clientid changes?
> 
> By <client-id> I meant a unique identifier for the client, not necessarily
> the nfsv4.x clientid.  The client could just as well use its ip address
> (to help admins deal with the aftermath in case the client goes away) and its
> boot time, or even a random string.

Like the current sillyrename, it'd help in some cases, but not all.  The
set of cases where it worked would be a little larger, but also a little
harder to explain.  There may be diminishing returns to trying to
perfect this kind of workaround.

With 4.1 almost actually ready time might be better spent there, as it
offers the chance of a complete solution.

--b.
