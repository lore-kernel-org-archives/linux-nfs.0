Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:10975 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932101Ab3EOTzf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 15:55:35 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFS: Fall back to AUTH_SYS for SETCLIENTID (take 2)
Date: Wed, 15 May 2013 19:55:34 +0000
Message-ID: <1368647734.3568.17.camel@leira.trondhjem.org>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net>
	 <20130513162528.1942.64673.stgit@seurat.1015granger.net>
	 <20130515160424.GK16811@fieldses.org>
	 <961AC5FB-617E-48FB-A35F-5E1A25213292@oracle.com>
	 <20130515171601.GL16811@fieldses.org> <20130515173916.GM16811@fieldses.org>
	 <D8763141-7185-499B-ADFA-659F9992269C@oracle.com>
	 <20130515174806.GO16811@fieldses.org>
	 <0B08EFEB-D651-4A68-8F1F-2078F62B6A5A@oracle.com>
	 <20130515195245.GC25994@fieldses.org>
In-Reply-To: <20130515195245.GC25994@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-05-15 at 15:52 -0400, J. Bruce Fields wrote:
> On Wed, May 15, 2013 at 03:28:27PM -0400, Chuck Lever wrote:
> > 
> > On May 15, 2013, at 1:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > > On Wed, May 15, 2013 at 01:42:58PM -0400, Chuck Lever wrote:
> > >> 
> > >> On May 15, 2013, at 1:39 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > >> 
> > >>> By the way, have you looked at SP4_MACH_CRED at all yet?  It's a
> > >>> selfish question (I could use something to test against), but I
> > >>> think it's also what you want if you want krb5i-protected 4.1 state.
> > >> 
> > >> I asked about that recently and was told SP4_MACH_CRED was going the
> > >> way of the do do
> > > 
> > > Do you remember who said that?  Is the discussion on line somewhere?
> > 
> > No, I mis-remembered.  I was thinking of SP4_SSV.
> > 
> > > 
> > >> (or did I misunderstand the response from the floor?).
> > >> 
> > >> I'm certainly open to exploring other solutions, but I do want to be
> > >> practical about it.  Will it be supported on other servers besides
> > >> Linux?  Does SP4_MACH_CRED help for NFSv4.0?
> > > 
> > > I haven't tested other servers.  It's a 4.1-only feature.
> > 
> > SP4_MACH_CRED for 4.1 appears useful, but I think we would need to consider:
> > 
> >   o  whether SP4_MACH_CRED is a broadly implemented feature where Linux
> >      clients can rely on it being there in typical environments
> 
> I'm assuming it's mandatory for servers to implement.  If there is any
> example of a released server not implementing SP4_MACH_CRED, I'd like to
> know.
> 
> >   o  how to address the "no keytab" issue for NFSv4.0, which does not
> >      have SP4_MACH_CRED (that I am aware of)
> > 
> > Andy is probably more interested in seeing SP4_MACH_CRED implemented in the Linux client, as it is one solution for the "user cred expired while there is still dirty data in the client's page cache" problem, I think.
> 
> OK.
> 
> The ability to perform writes using the machine credential is built on
> top of SP4_MACH_CRED, but is optional for servers to support.

Right, but given that they solve a real problem with secure NFS, I
expect that most servers will implement it eventually. For that reason,
we will be implementing it on the client. I just need to get the basic
NFSv4.1 state management stuff debugged first.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
