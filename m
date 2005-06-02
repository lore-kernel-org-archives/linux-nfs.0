From: Shantanu Goel <sgoel01@yahoo.com>
Subject: Re: [PATCH] Smooth out NFS client writeback
Date: Wed, 1 Jun 2005 20:26:09 -0700 (PDT)
Message-ID: <20050602032609.47381.qmail@web30715.mail.mud.yahoo.com>
References: <1117677369.10822.52.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-1913106082-1117682769=:47251"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdgLY-000064-Qw
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 20:26:16 -0700
Received: from web30715.mail.mud.yahoo.com ([68.142.201.253])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DdgLX-0008JE-Bl
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 20:26:16 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1117677369.10822.52.camel@lade.trondhjem.org>
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

--0-1913106082-1117682769=:47251
Content-Type: text/plain; charset=iso-8859-1
Content-Id: 
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Here are some numbers with iozone (avg of 3 runs).=20
The command was run as: iozone -i0 -r4k -s64m -c -t4
I manually booted the client machine with mem=3D256M.
It has 2 Xeon CPU's with hyperthreading enabled.  The
server is running 2.6.11.  The machines are on 100mb
ethernet.  The filesystem is mounted with
tcp,rsize=3D32768,wsize=3D32768.

                 Stock       w/Patch
parent write     7227        6155
parent rewrite   7068        6973
children write   7826       11659
children rewrite 7083        6974

I also ran iozone in mmap mode with same options as
above but specifying -B as well.  The machine hung
with the stock client so could not complete the test.=20
Here are the numbers with the patched client.

parent write     6350
parent rewrite   4167
children write   9375
children rewrite 4792

I also ran a latency test using the script I'm
attaching to this email.  The script was invoked as: =20
 write-test.pl 256m
It writes a 256MB and prints the time elapsed for each
5% increment.

Stock:

 5(0s)
10(0s)
15(0s)
20(0s)
25(0s)
30(7s)
35(3s)
40(1s)
45(0s)
50(0s)
55(0s)
60(7s)
65(3s)
70(0s)
75(0s)
80(1s)
85(0s)
90(7s)
95(3s)
100(0s)
sync(4s)

Throughput: 7084 KB/s (6 MB/s)

w/Patch:

 5(0s)
10(0s)
15(0s)
20(0s)
25(0s)
30(0s)
35(0s)
40(0s)
45(2s)
50(1s)
55(3s)
60(2s)
65(2s)
70(2s)
75(1s)
80(2s)
85(2s)
90(2s)
95(1s)
100(2s)
sync(11s)

Throughput: 7710 KB/s (7 MB/s)

--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:

> on den 01.06.2005 Klokka 18:38 (-0700) skreiv
> Shantanu Goel:
> > Hi Trond,
> >=20
> > The current NFS client can cause a program to
> stall
> > for long periods of time because it flushes all
> dirty
> > pages at once.  The attached patch addresses this
> by
> > only writing back the amount requested by the VM
> > layer.  It also reduces the # commit requests by
> > waiting for some writeback to complete before
> issuing
> > a commit.  The patch also speeds up writebacks of
> > mmap'ed data by accumulating dirty pages but
> sending
> > commits earlier and omitting FLUSH_STABLE.
>=20
> Hi Shantanu,
>=20
> Do you have any figures on this subject? I'd very
> much like to see how
> this changes the figures for both the throughput and
> the latency. We
> should look at both slow and fast networks (say
> 10Mbit, 100Mbit &
> 1GigE).
>=20
> My other question is how it affects stability in the
> case of low memory
> situations?
>=20
> Cheers,
>   Trond
>=20
>=20

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20
--0-1913106082-1117682769=:47251
Content-Type: application/x-perl; name="write-test.pl"
Content-Transfer-Encoding: base64
Content-Description: 3263050112-write-test.pl
Content-Disposition: attachment; filename="write-test.pl"

IyEvdXNyL2Jpbi9wZXJsIC13Cgp1c2Ugc3RyaWN0Owp1c2UgSU86OkZpbGU7
CgpteSAkYnNpemUgPSA0MDk2OwpteSAkc2l6ZTsKCmlmIChAQVJHVikgewog
ICAgaWYgKCRBUkdWWzBdIGVxICctYicpIHsKCXNoaWZ0IEBBUkdWOwoJaWYg
KEBBUkdWKSB7CgkgICAgJGJzaXplID0gc2hpZnQgQEFSR1Y7CgkgICAgaWYg
KCRic2l6ZSA9fiAvXihcZCspayQvaSkgewoJCSRic2l6ZSA9ICQxICogMTAy
NDsKCSAgICB9IGVsc2lmICgkYnNpemUgPX4gL14oXGQrKW0kL2kpIHsKCQkk
YnNpemUgPSAkMSAqIDEwMjQgKiAxMDI0OwoJICAgIH0gZWxzaWYgKCRic2l6
ZSAhfiAvXihcZCspJC8pIHsKCQlkaWUgImludmFsaWQgYmxvY2sgc2l6ZVxu
IjsKCSAgICB9Cgl9CiAgICB9CiAgICBpZiAoQEFSR1YpIHsKCSRzaXplID0g
c2hpZnQgQEFSR1Y7CglpZiAoJHNpemUgPX4gL14oXGQrKWckL2kpIHsKCSAg
ICAkc2l6ZSA9ICQxICogMTAyNCAqIDEwMjQ7Cgl9IGVsc2lmICgkc2l6ZSA9
fiAvXihcZCspbSQvaSkgewoJICAgICRzaXplID0gJDEgKiAxMDI0OwoJfSBl
bHNpZiAoJHNpemUgPX4gL14oXGQrKWskL2kpIHsKCSAgICAkc2l6ZSA9ICQx
OwoJfSBlbHNlIHsKCSAgICBkaWUgImludmFsaWQgc2l6ZVxuIjsKCX0KICAg
IH0KfQp1bmxlc3MgKCRzaXplKSB7CiAgICBvcGVuKE1FTSwgIi9wcm9jL21l
bWluZm8iKSB8fCBkaWUgJCE7CiAgICB3aGlsZSAoPE1FTT4pIHsKCWlmICgv
Xk1lbVRvdGFsXHMqOlxzKihcZCspLykgewoJICAgICRzaXplID0gJDE7Cgl9
IGVsc2lmICgvXk1hcHBlZFxzKjpccyooXGQrKS8pIHsKCSAgICAkc2l6ZSAt
PSAkMTsKCX0KICAgIH0KICAgIGNsb3NlKE1FTSk7CiAgICAkc2l6ZSA9IGlu
dCgkc2l6ZSAqIDMgLyAyKTsKICAgIHByaW50ICJzaXplID0gJHNpemUgS0Ii
OwogICAgbXkgJG1iID0gaW50KCRzaXplIC8gMTAyNCk7CiAgICBwcmludCAi
ICgkbWIgTUIpIiBpZiAoJG1iKTsKICAgIHByaW50ICJcbiI7Cn0KCiR8ID0g
MTsKbXkgJHRlc3RmID0gJy53cml0ZS50ZXN0JzsKbXkgJGlvID0gbmV3IElP
OjpGaWxlKCI+JHRlc3RmIikgb3IgZGllICQhOwpteSAkcGN0ID0gNTsKbXkg
JGRvbmUgPSAwOwpteSAkYnVmID0gJzAnIHggJGJzaXplOwpteSAkc3RhcnQg
PSB0aW1lOwpteSAkdG90YWwgPSAkc3RhcnQ7CndoaWxlICgkZG9uZSA8ICRz
aXplKSB7CiAgICBteSAkbiA9ICRpby0+c3lzd3JpdGUoJGJ1ZiwgJGJzaXpl
KTsKICAgIGRpZSAic3lzd3JpdGU6ICQhIiB1bmxlc3MgKGRlZmluZWQgJG4g
JiYgJG4gPT0gJGJzaXplKTsKICAgICRkb25lICs9IGludCgkYnNpemUgLyAx
MDI0KTsKICAgIG15ICRwID0gaW50KCRkb25lICogMTAwIC8gJHNpemUpOwog
ICAgaWYgKCRwID49ICRwY3QpIHsKCW15ICR0ID0gdGltZTsKCXByaW50ICIg
JHAoIiwgKCR0IC0gJHN0YXJ0KSwgInMpIjsKCSRwY3QgPSAkcCArIDU7Cgkk
c3RhcnQgPSAkdDsKICAgIH0KfQokaW8tPnN5bmM7CiRpby0+Y2xvc2U7CnBy
aW50ICIgc3luYygiLCAodGltZSAtICRzdGFydCksICJzKVxuIjsKbXkgJHQg
PSB0aW1lIC0gJHRvdGFsOwpteSAka2JzID0gaW50KCRzaXplIC8gKCR0ICsg
MSkpOwpteSAkbWJzID0gaW50KCRrYnMgLyAxMDI0KTsKcHJpbnQgIiRrYnMg
S0IvcyI7CnByaW50ICIgKCRtYnMgTUIvcykiIGlmICgkbWJzKTsKcHJpbnQg
IlxuIjsKdW5saW5rKCR0ZXN0Zik7Cg==

--0-1913106082-1117682769=:47251--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
