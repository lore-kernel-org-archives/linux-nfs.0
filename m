Return-Path: SteveD@redhat.com
Message-ID: <5464F10D.3010402@RedHat.com>
Date: Thu, 13 Nov 2014 12:57:33 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>	<CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>	<5462608B.1090607@RedHat.com>	<CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com>	<54635BB5.1020702@RedHat.com>	<CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com>	<5463787A.7080404@RedHat.com>	<CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com>	<43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com>	<5463A282.8060803@RedHat.com>	<CAHQdGtTV_XW94GTeyFh+jMQ8EzkuTHv9dF+V0KMO+pqYMT3yrw@mail.gmail.com>	<5463C066.8030205@Netapp.com>	<5463C3F8.50004@RedHat.com> <CAHQdGtSnz84ymSC0n=vb5yMPj+ZfgJw=PMeDOhpvQHPwK+eq3A@mail.gmail.com>
In-Reply-To: <CAHQdGtSnz84ymSC0n=vb5yMPj+ZfgJw=PMeDOhpvQHPwK+eq3A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2014 05:42 PM, Trond Myklebust wrote:
>>> NFS v4.0, 4.1, and 4.2 are all part of the same module, though.  Is there a way to analyze modules and determine what is compiled in?
>> > Maybe come up with some global bit field could be used?
>> > Each bit signifies a minor version is enabled...
>> >
> No. This means that mount.nfs now suddenly needs to know the names of
> the NFS modules and how to load them before it calls mount() just so
> that it knows which parameters to try. This is a rathole we don't want
> to explore...
I don't think mount.nfs needs to know any names... Just 
a file /proc/fs/nfs/mount that tells mount.nfs where
to start the negotiation....

steved.
 
