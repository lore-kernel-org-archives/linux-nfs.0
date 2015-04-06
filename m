Return-Path: <sean.brisbane@physics.ox.ac.uk>
From: Sean Brisbane <sean.brisbane@physics.ox.ac.uk>
To: Benjamin Coddington <bcodding@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Per process accounting for nfs
Date: Mon, 6 Apr 2015 16:51:13 +0000
Message-ID: <C6A70F0B3785A04BA88C056A0B39627C21A2023C@EXCHNG15.physics.ox.ac.uk>
References: <C6A70F0B3785A04BA88C056A0B39627C21A1BAB4@EXCHNG15.physics.ox.ac.uk>,<alpine.OSX.2.19.9992.1504021537360.710@planck.local>
In-Reply-To: <alpine.OSX.2.19.9992.1504021537360.710@planck.local>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Dear Ben,=0A=
=0A=
System tap is exactly what I was looking for, and more.  Ftrace looks promi=
sing too, but systemtap has an example script that nearly matches the use c=
ase.=0A=
=0A=
Thank you for your help.=0A=
Sean=0A=
________________________________________=0A=
From: Benjamin Coddington [bcodding@redhat.com]=0A=
Sent: 02 April 2015 20:50=0A=
To: Sean Brisbane=0A=
Cc: linux-nfs@vger.kernel.org=0A=
Subject: Re: Per process accounting for nfs=0A=
=0A=
On Thu, 2 Apr 2015, Sean Brisbane wrote:=0A=
=0A=
> Dear All,=0A=
>=0A=
> I'm currently trying to identify a mechanism to measure NFS I/o per proce=
ss on a multi user NFS client machine. Lots of googling tells me this is no=
t straight forward. Installing a kernel or module is an option if necessary=
, though we are also supporting afs and lustre on the same kernel (RHEL 6 b=
ased). The purpose of this is to gather accurate metrics on the workload ty=
pes we run to feed into what hardware we need to buy. Can anyone give me an=
y pointers as to how to proceed?=0A=
>=0A=
> Thanks,=0A=
=0A=
=0A=
Hi Sean,=0A=
=0A=
Systemtap can do that.. and ftrace might also work for that.  Check those=
=0A=
out.=0A=
=0A=
Ben=0A=
