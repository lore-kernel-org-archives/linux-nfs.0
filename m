Return-Path: bfields@fieldses.org
Date: Thu, 13 Nov 2014 14:02:13 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
Message-ID: <20141113190213.GA28516@fieldses.org>
References: <5463787A.7080404@RedHat.com>
 <CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com>
 <43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com>
 <5463A282.8060803@RedHat.com>
 <CAHQdGtTV_XW94GTeyFh+jMQ8EzkuTHv9dF+V0KMO+pqYMT3yrw@mail.gmail.com>
 <5463C066.8030205@Netapp.com>
 <5463C3F8.50004@RedHat.com>
 <CAHQdGtSnz84ymSC0n=vb5yMPj+ZfgJw=PMeDOhpvQHPwK+eq3A@mail.gmail.com>
 <5464F10D.3010402@RedHat.com>
 <CAHQdGtTqJDBTKZ3e9u3FgRjRbTFapEh+nYi0i+yy02Dar-ypPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTqJDBTKZ3e9u3FgRjRbTFapEh+nYi0i+yy02Dar-ypPA@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 01:52:09PM -0500, Trond Myklebust wrote:
> On Thu, Nov 13, 2014 at 12:57 PM, Steve Dickson <SteveD@redhat.com> wrote:
> > On 11/12/2014 05:42 PM, Trond Myklebust wrote:
> >>>> NFS v4.0, 4.1, and 4.2 are all part of the same module, though.  Is there a way to analyze modules and determine what is compiled in?
> >>> > Maybe come up with some global bit field could be used?
> >>> > Each bit signifies a minor version is enabled...
> >>> >
> >> No. This means that mount.nfs now suddenly needs to know the names of
> >> the NFS modules and how to load them before it calls mount() just so
> >> that it knows which parameters to try. This is a rathole we don't want
> >> to explore...
> > I don't think mount.nfs needs to know any names... Just
> > a file /proc/fs/nfs/mount that tells mount.nfs where
> > to start the negotiation....
> >
> 
> The kernel does not have that information until the NFSv4 module is loaded.

I still don't get it.  All it needs to know is an upper bound--that
could be a single compile-time constant.  Is there any reason not to
build that number into the main nfs module?

--b.
