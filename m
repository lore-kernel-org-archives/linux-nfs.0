From: Greg Banks <gnb@sgi.com>
Subject: Re: simple question about r/wsize
Date: Mon, 8 Oct 2007 18:54:00 +1000
Message-ID: <20071008085400.GB30931@sgi.com>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD8447540@exchrdm.ad.xensource.com>
	<1191280261.6611.19.camel@heimdal.trondhjem.org>
	<4701B24C.2070102@oxeva.fr>
	<1191294340.6611.34.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Wim Colgate <Wim.Colgate@xensource.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IeoFy-0003DK-2J
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 01:46:30 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX195l16bJlaUckZx6ymMbRhav+/hwpOtCQM=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IeoG2-0001zP-40
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 01:46:35 -0700
In-Reply-To: <1191294340.6611.34.camel@heimdal.trondhjem.org>
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

On Mon, Oct 01, 2007 at 11:05:40PM -0400, Trond Myklebust wrote:
> On Tue, 2007-10-02 at 04:51 +0200, Gabriel Barazer wrote:
> > On 10/02/2007 1:11:01 AM +0200, Trond Myklebust 
> > <trond.myklebust@fys.uio.no> wrote:
> > > On Mon, 2007-10-01 at 15:04 -0700, Wim Colgate wrote:
> > >> What???s the current NFS v3 wsize and rsize? It appears to be 4K ??? and
> > >> just wanted a confirmation.
> > >>
> > > 
> > > It sounds like you are working with an old system. IIRC, older versions
> > > of RedHat used to jimmy the 'mount' command to make 4k the default,
> > > because that worked best with UDP mounts on crummy networks.
> > > 
> > > For newer clients, the default should depend on what your server
> > > specifies in the FSINFO nfs command. For most servers, when you mount
> > > with a TCP connection, the default will be 32k, but some may have larger
> > > defaults (NetApp servers often specify a 64k default) or smaller (older
> > > Linux servers will support an 8k maximum).
> > 
> > I see on my servers (>2.6.21, latest nfs-utils) that the rsize/wsize is 
> > actually defined by the amount of memory on the NFS server. It seems to 
> > set the rsize/wsize to (total memory)/8192 (512k in my case for a 4GB 
> > nfs server). Is it a bug or a wanted behavior ?
> 
> On a standard 2.6.23-rc8, the server sets RPCSVC_MAXPAYLOAD_TCP == 1MB,
> RPCSVC_MAXPAYLOAD_UDP == 32k. There is no link to the total amount of
> memory.

I think Gabriel may be referring to this code in fs/nfsd/nfssvc.c

202         if (nfsd_max_blksize == 0) {
203                 /* choose a suitable default */
204                 struct sysinfo i;
205                 si_meminfo(&i);
206                 /* Aim for 1/4096 of memory per thread
207                  * This gives 1MB on 4Gig machines
208                  * But only uses 32K on 128M machines.
209                  * Bottom out at 8K on 32M and smaller.
210                  * Of course, this is only a default.
211                  */
212                 nfsd_max_blksize = NFSSVC_MAXBLKSIZE;
213                 i.totalram <<= PAGE_SHIFT - 12;
214                 while (nfsd_max_blksize > i.totalram &&
215                        nfsd_max_blksize >= 8*1024*2)
216                         nfsd_max_blksize /= 2;
217         }

You can override this default by writing to
/proc/fs/nfsd/max_block_size (before the first nfsd is started,
which basically means modifying /etc/init.d/nfsserver).

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
