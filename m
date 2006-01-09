From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: NFS performance tuning
Date: Sun, 8 Jan 2006 17:17:32 -0800
Message-ID: <OFDC1A84DC.085D116A-ON882570F1.0005D98F-882570F1.0006D002@us.ibm.com>
References: <1136758155.7849.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: NFS List <nfs@lists.sourceforge.net>,
	nfs-admin@lists.sourceforge.net, Ian Kent <raven@themaw.net>,
	Stephen Carville <stephen@totalflood.com>
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <1136758155.7849.11.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

I tried lately to change the max block size on the client and server from 
32K to 64K and I got 36K. Looking at the code it looked like it got the 
size from
 
max_rpc_payload = nfs_block_size(rpc_max_payload(server->client), NULL);
        if (server->rsize > max_rpc_payload)

and max_payload was set by the network driver.

Marc.

nfs-admin@lists.sourceforge.net wrote on 01/08/2006 02:09:15 PM:

> On Sun, 2006-01-08 at 13:10 -0800, Marc Eshel wrote:
> > nfs-admin@lists.sourceforge.net wrote on 01/08/2006 12:22:13 PM:
> > 
> > > On Sat, 2006-01-07 at 23:44 -0800, Blake Golliher wrote:
> > > > The linux nfs client supports, at least, a 64k block transfer 
size.  I 
> > 
> > > > don't believe it's constrained by transport protocol.
> > > 
> > > That is a very recent feature, though. Unless you are using the 
NFS_ALL
> > > patches, you will only get 64k block transfer sizes on the very 
latest
> > > GIT tarball. ;-)
> > > 
> > > Cheers,
> > >   Trond
> > > 
> > 
> > But is still constrained by the transport protocol.
> > Marc.
> 
> Yes. UDP won't allow you to use 64k read/write sizes since that would
> overflow the size of a datagram. TCP has no such inherent limitation,
> though.
> 
> Cheers,
>   Trond
> 
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc. Do you grep through log 
files
> for problems?  Stop!  Download the new AJAX search engine that makes
> searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
> http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
