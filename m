Return-Path: SteveD@redhat.com
Message-ID: <5463C35C.50804@RedHat.com>
Date: Wed, 12 Nov 2014 15:30:20 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
References: <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com> <5462608B.1090607@RedHat.com> <CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com> <54635BB5.1020702@RedHat.com> <CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com> <5463787A.7080404@RedHat.com> <CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com> <43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com> <5463A282.8060803@RedHat.com> <CAHQdGtTV_XW94GTeyFh+jMQ8EzkuTHv9dF+V0KMO+pqYMT3yrw@mail.gmail.com> <20141112200702.GA8790@fieldses.org>
In-Reply-To: <20141112200702.GA8790@fieldses.org>
Content-Type: text/plain; charset=windows-1252
List-ID: <linux-nfs.vger.kernel.org>



On 11/12/2014 03:07 PM, J. Bruce Fields wrote:
> On Wed, Nov 12, 2014 at 01:41:03PM -0500, Trond Myklebust wrote:
>> The NFS client modules are loaded on demand. The kernel will therefore
>> not actually know the capabilities until we attempt the mount.
> 
> Right, but the main nfs module can know at least an upper bound, and
> that's all mount needs to start negotiation, isn't it?  If the kernel
> thinks 4.99 is supported but in fact that module turns out to be
> blacklisted or something, then we can always try it and fall back.
> 
Right, all mount.nfs needs to know is where to start... 

I was thinking mount.nfs to try to load the module but
that's probably not a good idea... 

steved.
