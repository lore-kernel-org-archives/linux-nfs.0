From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: A new NFSv4 server...
Date: Sat, 05 Jan 2008 09:56:03 +0200
Message-ID: <477F3813.70204@panasas.com>
References: <477CD231.30603@garzik.org>
	<20080103163200.GB30029@fieldses.org>	<477DC501.3060104@garzik.org>
	<477DD11B.40909@melbourne.sgi.com>
	<477DDA86.6020100@garzik.org> <477DF761.8040306@panasas.com>
	<477E557C.3000104@garzik.org> <477EE182.6020108@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <477EE182.6020108@melbourne.sgi.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Greg Banks wrote:
> Strongly agreed with all the above.  It's difficult to avoid the
> conclusion that the current pNFS spec is designed to allow the
> existing parallel filesystem vendors to sell "standards compliant"
> solutions that only work with their client software and where all
> the MDS and DS machines need to be bought from the same vendor.
> If the spec defined a single layout type, and all three protocols
> involved were variants of NFSv4.1 and were defined in the spec,
> we would have a true open standard.
>
>   
Greg, I'm afraid your conclusion is just wrong.  What exactly is it 
based on?
I'd appreciate if you could look again at the current Internet Drafts 
comprising
NFSv4.1 and layout types and please raise any issues you see in the specs
that would jeopardize interoperability between different client software 
vendors
and different server / storage vendors.

http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1
http://tools.ietf.org/html/draft-ietf-nfsv4-pnfs-obj
http://tools.ietf.org/html/draft-ietf-nfsv4-pnfs-block

There is indeed a third protocol in the overall architecture used by the 
MDS to manage
the storage devices and this protocol is outside the scope of NFSv4.1.  
This may lead
to non-interoperable implementations of server/storage systems but that 
definitely was
not the intent of the design decision to leave the storage management 
protocol unspecified
in NFSv4.1.

The object-based layout type. for example. is based on using the 
standard OSD protocol
between the MDS and the OSDs for control as well as between the clients 
and the OSDs
for data transfer.  How does that preclude interoperability between 
different client, MDS,
and DS vendors if the MDS, OSDs, and clients comply with T-10 OSD and 
MDS and
client comply with NFSv4.1 and the pnfs-obj RFC (when it becomes one)?

Benny
