From: "Shankar Anand" <shanand@novell.com>
Subject: Re: PATCH [1/2] Capture nfsv4 server operations statistics
Date: Sat, 20 May 2006 02:07:34 -0600
Message-ID: <446F1B9F.AD69.00CC.0@novell.com>
References: <4469C82B.AD69.00CC.0@novell.com>
 <20060517213638.GE11237@fieldses.org> <446E3040.AD69.00CC.0@novell.com>
 <20060519162747.GI3721@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <nfsv4@linux-nfs.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FhMTR-0001Ol-0L
	for nfs@lists.sourceforge.net; Sat, 20 May 2006 01:06:09 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FhMTQ-0002kQ-SW
	for nfs@lists.sourceforge.net; Sat, 20 May 2006 01:06:08 -0700
Received: from lucius.provo.novell.com ([137.65.81.172])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FhMTO-0007Dm-Lu
	for nfs@lists.sourceforge.net; Sat, 20 May 2006 01:06:08 -0700
To: "J. Fields" <bfields@fieldses.org>
In-Reply-To: <20060519162747.GI3721@fieldses.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

> On 5/19/2006 at 9:57:47 pm,
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Fri, May 19, 2006 at 09:23:20AM -0600, Shankar Anand wrote:
>> Verified compilation when nfsv4 is configured out. And also=20
>> made changes so that the nfsv4 operation statistics are captured
>> only when nfsv4 is configured.
>=20
> Thanks!  Looks fine to me.
>=20
> One last thing I wonder about--the current /proc/net/rpc/nfsd ends with
> lines like:
>=20
> proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> proc3 22 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> proc4 2 4 172
>=20
> where the two operations counted on the last line are NULL and COMPOUND.
> You're appending one more line, to make:
>=20
> proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> proc3 22 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> proc4 2 4 172
> proc4ops 37 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> 0 0 0 0 0 0 0
>=20
> I like the fact that that doesn't bother the preexisting proc4 line.  On
> the other hand, as far as we know nobody's ever used the data on that
> line, and it's hard to see how they would in the future (the number of
> NULL calls to the server isn't very important), so may it would be
> simplest just to replace the proc4 line entirely, as was done on the
> client side.
>=20
> Any strong opinions from anyone else?

There are some small issues in doing that.

The proc2, proc3 and proc4 lines get written into the /proc file by=20
rpc_proc_show() function in sunrpc library unlike the proc4ops line =
that=20
I have written now, which gets written into /proc file at nfs level in=20
nfs_proc_show().

All the procedures that are registered as rpc procedures, get their =
statistics=20
recorded in the /proc file in the sunrpc rpc_proc_show() function. If =
we=20
have to avoid the original proc4 line, we will have to introduce a special =
case=20
to specifically refrain from writing v4 rpc statistics into the /proc =
file,=20
which may not be appropriate.

In the client, all the procedures are registered as rpc procedures in =
nfs4xdr.c.
Hence, the proc4 line for the client contains all the v4 procedures.

Cheers,
Shankar



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
