From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs write problems
Date: Tue, 02 Oct 2007 20:07:39 -0400
Message-ID: <1191370059.6707.38.camel@heimdal.trondhjem.org>
References: <4702A279.3080001@panix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: For users of Fedora <fedora-list@redhat.com>,
	nfs@lists.sourceforge.net
To: Bob Kryger <bobk@panix.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Icrmo-0001W3-P7
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 17:08:22 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Icrmt-00013i-B8
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 17:08:27 -0700
In-Reply-To: <4702A279.3080001@panix.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2007-10-02 at 15:56 -0400, Bob Kryger wrote:
> So, I have a relatively new system on which I am seeing strange NFS 
> behavior.
> 
> In short I am getting seemingly random errors in files written via NFS.
> 
>     * I do not get the errors if I write files locally.
>     * I have no errors in the NIC, I even tried a second NIC in a PCI
>       slot as opposed to the onboard one. There are no errors recorded
>       on the NIC or the switch on a 1Gb port.
>     * I see no memory errors, I ran memtest for 3 days clean.
>     * To test I am using dd if=/dev/zero of various (large) file sizes.
>     * Since I know that the file should be all zeros I wrote a C program
>       to read it back and tell me where it finds non-zero bytes. The
>       program results are confirmed with od.
>     * The files read back always have the errors in the same place, so
>       it is not a problem with reading the files.
>     * There are no errors in any logs.
>     * The problem occurs on both the RAID1 (ext3) and RAID10 (xfs)
>       filesystems.
>     * I've tried two clients, both FC5 one 64bit, and the other a 32 bit
>       with the same results. This error was uncovered by users
>       attempting to write files from other systems and other Fedora
>       releases, so it is repeatable regardless of the client.
>     * the server is not running anything else and spends a large portion
>       of the time idle. loadaverages are quite low. swap is mostly
>       unused. a large portion of RAM is allocated to file cache, but I
>       expect that this would be normal for this amount of file IO.
> 
> The server is running an up-to-date FC6, although this also occurred 
> with FC5. I am about to try F7.
> 
> Hardware is an AMD 1220 dual core 64bit, on a Tyan K8SSA S3950
> with an Adaptec Raid 2230SLP and 7 Fujitsu MAU3147NC.
> The RAID config is that 1 disks (on diff channels) are in a Mirror for 
> the OS, 4 are in a Raid 10 config and 1 is a hot spare.
> 
> Anyone ever seen anything like this before?
> Suggest where I might look next?
> Additional tests?

Feel free to describe your test in a bit more detail. Without more
information, we obviously can't rule out the existence of an NFS bug,
however usually whenever people describe this sort of problem it is
because they have failed to understand the NFS caching model as
described in

    http://nfs.sourceforge.net/#faq_a8

So please include a reproducible test for us.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
