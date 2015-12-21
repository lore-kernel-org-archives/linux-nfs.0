Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44551 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbbLUQry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Dec 2015 11:47:54 -0500
Date: Mon, 21 Dec 2015 11:47:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Soumya Koduri <skoduri@redhat.com>
Cc: Omar Walid Llorente <omar@dit.upm.es>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        =?utf-8?Q?administraci=C3=B3n_del_centro_de_c=C3=A1lculo?= del
	 dit <cdc@dit.upm.es>
Subject: Re: possible bug in nfs-kernel-server
Message-ID: <20151221164752.GA7869@fieldses.org>
References: <5669702D.50402@redhat.com>
 <20151210144434.GB12544@fieldses.org>
 <566EF4E4.60809@dit.upm.es>
 <5672A78D.4090303@redhat.com>
 <20151218003722.GA1452@us.ibm.com>
 <5673C73C.2030109@redhat.com>
 <20151218152039.GC25074@fieldses.org>
 <56743FB6.80903@redhat.com>
 <20151218200840.GA28692@fieldses.org>
 <5677BCD4.4060009@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5677BCD4.4060009@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 21, 2015 at 02:18:20PM +0530, Soumya Koduri wrote:
> 
> 
> On 12/19/2015 01:38 AM, J. Bruce Fields wrote:
> >On Fri, Dec 18, 2015 at 10:47:42PM +0530, Soumya Koduri wrote:
> >>
> >>
> >>On 12/18/2015 08:50 PM, J. Bruce Fields wrote:
> >>>On Fri, Dec 18, 2015 at 02:13:40PM +0530, Soumya Koduri wrote:
> >>>>
> >>>>
> >>>>On 12/18/2015 06:07 AM, Malahal Naineni wrote:
> >>>>>IIRC, permission checks are done in open(). write/read syscalls should
> >>>>>NOT do much access checks (at least based on POSIX). This is why once an
> >>>>>open is done, you remove permissions for that process, but it should
> >>>>>still be able to read/write based on the open flags it did when it
> >>>>>opened the file.
> >>>>>
> >>>>>I don't know all the details of this defect, but gluster seems to be
> >>>>>doing what it is supposed to do.
> >>>>>
> >>>>Right. Thanks for the correction. I assumed the behavior should be
> >>>>same for both OPEN+WRITE vs CREATE+WRITE in the below scenario. But
> >>>>looks like (from 'man creat')  the open() call that creates a
> >>>>read-only file may well return a read/write file descriptor, which
> >>>>is the reason the following WRITE can succeed.
> >>>
> >>>I forgot another complication, which is that knsfd actually does a
> >>>temporary open before each read or write--I assume that's getting
> >>>translated into fuse and gluster open operations?
> >>>
> >>yes. It is the OPEN done as part of NFS WRITE which fails with
> >>EACCESS error (with both NFSv3 and NFSv4 mounts).
> >
> >Makes sense for v3, but I wouldn't normally expect the extra temporary
> >open on v4 WRITEs.  Could you share any details?
> >
> I re-tried the test on v4 mount using Fedora23 machine, acting as
> both NFS server and client (Linux#4.2.3-300.fc23.x86_64). Please
> find the pkt trace attached.
> 
>  56 07:23:25.567134          ::1 -> ::1          NFS 288 V4 Call
> WRITE StateID: 0xf934 Offset: 0 Len: 7
>  57 07:23:25.567233 192.168.122.17 -> 192.168.122.202 GlusterFS 188
> V330 GETXATTR Call
>  58 07:23:25.567732 192.168.122.202 -> 192.168.122.17 GlusterFS 112
> V330 GETXATTR Reply (Call In 57)
>  59 07:23:25.567881 192.168.122.17 -> 192.168.122.202 GlusterFS 164
> V330 OPEN Call

Remind me what kernel version your server is on?

--b.


>  60 07:23:25.568354 192.168.122.202 -> 192.168.122.17 GlusterFS 116
> V330 OPEN Reply (Call In 59)
>  61 07:23:25.568570          ::1 -> ::1          NFS 144 V4 Reply
> (Call In 56) WRITE Status: NFS4ERR_ACCESS
> 
> Thanks,
> Soumya
> 
> >--b.
> >
> >>
> >>  63 16:59:09.278651000          ::1 -> ::1          NFS 232 V3 WRITE
> >>Call, FH: 0x49a35e54 Offset: 0 Len: 7 FILE_SYNC
> >>  64 16:59:09.278926000 192.168.122.1 -> 192.168.122.202 GlusterFS
> >>164 V330 OPEN Call
> >>  65 16:59:09.278937000 192.168.122.1 -> 192.168.122.202 GlusterFS
> >>164 [RPC retransmission of #64][TCP Retransmission] V330 OPEN Call
> >>  66 16:59:09.279459000 192.168.122.202 -> 192.168.122.1 GlusterFS
> >>116 V330 OPEN Reply (Call In 64)
> >>  67 16:59:09.279459000 192.168.122.202 -> 192.168.122.1 GlusterFS
> >>116 [RPC duplicate of #66][TCP Retransmission] V330 OPEN Reply (Call
> >>In 64)
> >>  68 16:59:09.279733000          ::1 -> ::1          NFS 212 V3 WRITE
> >>Reply (Call In 63) Error: NFS3ERR_ACCES
> >>
> >>
> >>Thanks,
> >>Soumya
> >>
> >>>In which case it might be worth experimenting with NFSv4 or with Jeff
> >>>Layton's filehandle-caching patches.  Neither's a real fix, but that
> >>>could help confirm whether it's the temporary opens that are a problem.
> >>>
> >>>--b.
> >>>
> >>>>
> >>>>Thanks,
> >>>>Soumya
> >>>>
> >>>>
> >>>>>Regards, Malahal.
> >>>>>
> >>>>>Soumya Koduri [skoduri@redhat.com] wrote:
> >>>>>>As mentioned by Bruce, GlusterFS doesn't have owner-override rule
> >>>>>>except for setattr.
> >>>>>>
> >>>>>>I did few experiments to check why this test case passes on plain
> >>>>>>glusterfs fuse mount & NFS-Ganesha but fails with kernel-NFS.
> >>>>>>
> >>>>>>NFS-Ganesha (for most of the FSALs) seem to be passing the actual
> >>>>>>request credentials to the back-end filesystem only for
> >>>>>>CREATE(-like) and UNLINK fops. For all the remaining fops, it does
> >>>>>>the access check at its end and then perform the operation with root
> >>>>>>credentials. That's the reason WRITE succeeded in your case as
> >>>>>>NFS-Ganesha (like kernel-NFS) skipped the access check if the
> >>>>>>request caller_uid proved to be the file's owner.
> >>>>>>
> >>>>>>In case of native GlusterFS FUSE mount, there is no OPEN fop
> >>>>>>involved. WRITE is performed on the fd returned by CREATE. And
> >>>>>>strangely GlusterFS seem to be doing certain access checks only
> >>>>>>during OPEN but not for WRITE (this seems like a bug and probably
> >>>>>>needs to be fixed in Gluster).
> >>>>>>
> >>>>>>Thanks,
> >>>>>>Soumya
> >>>>>>
> >>>>>>On 12/14/2015 10:27 PM, Omar Walid Llorente wrote:
> >>>>>>>
> >>>>>>>Thank you Bruce, others, for the responses. I send attached a complete
> >>>>>>>capture of the issue, including the glusterfs transactions.
> >>>>>>>
> >>>>>>>Hope this helps to clear where may it be...
> >>>>>>>
> >>>>>>>Omar
> >>>>>>>
> >>>>>>>El 10/12/15 a las 15:44, J. Bruce Fields escribió:
> >>>>>>>>On Thu, Dec 10, 2015 at 05:59:33PM +0530, Soumya Koduri wrote:
> >>>>>>>>>
> >>>>>>>>>On 12/10/2015 04:02 PM, Omar Walid Llorente wrote:
> >>>>>>>>>>Hi, Jeff, Bruce, finally I got some time to get the capture of the nfs
> >>>>>>>>>>packets (you can find them in attached file nfs-problem-nks.pcap.zip).
> >>>>>>>>>>Sorry for being so late.
> >>>>>>>>>>
> >>>>>>>>>>What I did was the following:
> >>>>>>>>>>
> >>>>>>>>>>1st) Create the RO file:
> >>>>>>>>>>cdc@l056:~/prueba-git$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt;
> >>>>>>>>>>chmod 444 444.txt;
> >>>>>>>>>>
> >>>>>>>>>>2nd) Init the capture:
> >>>>>>>>>>root@l056:~# tcpdump -i eth2 -w /tmp/nfs.pcap -s 512 port 2049
> >>>>>>>>>>tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size
> >>>>>>>>>>512 bytes
> >>>>>>>>>>
> >>>>>>>>>GlusterFS protocol is added to wireshark from version 1.8.0 [1]. It
> >>>>>>>>>may be helpful to see what GlusterFS operations are being processed
> >>>>>>>>>as part of NFS WRITE call (which has failed in this case).
> >>>>>>>>>
> >>>>>>>>>Could you please try taking the packet trace on the machine where
> >>>>>>>>>NFS server is running (without filtering out based on the port
> >>>>>>>>>number).
> >>>>>>>>>
> >>>>>>>>>Also I tried out the same test on Fedora22 machine, but haven't run
> >>>>>>>>>into any issue. What are the fuse mount options you have used to
> >>>>>>>>>mount gluster volume?
> >>>>>>>>Oh, I think this is a simple problem (but maybe hard to fix).  The
> >>>>>>>>capture shows NFSv3 traffic like:
> >>>>>>>>
> >>>>>>>>    CREATE -> OK
> >>>>>>>>    SETATTR (mode set to 0400) -> OK
> >>>>>>>>    WRITE -> NFS3ERR_ACCES
> >>>>>>>>
> >>>>>>>>That write would succeed locally (because the mode doesn't matter to a
> >>>>>>>>local application that already holds the file open).  It would fail over
> >>>>>>>>NFSv3, which doesn't know about the open--except that there's a hack for
> >>>>>>>>this case: NFSv3 servers allow IO operations to ignore the mode, if the
> >>>>>>>>operation comes from the owner of the file.  NFSv3 clients are then
> >>>>>>>>careful to perform necessary access checks on open to ensure that this
> >>>>>>>>owner-override rule doesn't grant too many permissions.
> >>>>>>>>
> >>>>>>>>That allows NFSv3 applications to see behavior that's mostly like a
> >>>>>>>>local filesystem, without opening much of a security hole (since the
> >>>>>>>>owner could always chmod anyway).
> >>>>>>>>
> >>>>>>>>So, knfsd is making this special exception--but gluster (which I believe
> >>>>>>>>it's exporting in this case, via fuse?)--probably doesn't....  I'm not
> >>>>>>>>sure what you can do about that.
> >>>>>>>>
> >>>>>>>>--b.
> >>>>>>>
> >>>>>>--
> >>>>>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>>>>>the body of a message to majordomo@vger.kernel.org
> >>>>>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>>>>
> >>>>>
> >--
> >To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >


