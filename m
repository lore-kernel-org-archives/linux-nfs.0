From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfs-utils 1.0.5 break amd?
Date: 04 Aug 2003 23:38:46 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1060033126.1354.118.camel@localhost>
References: <1059672742.21271.58.camel@ikarus>
	 <16169.55986.854984.818132@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mxout.hispeed.ch ([62.2.95.247] helo=smtp.hispeed.ch)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jn4a-0002Ph-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 14:40:56 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16169.55986.854984.818132@gargle.gargle.HOWL>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Ion is right, it's not the amd and Neil, you're right, too, `showmount
-e` is the way to go. :)

Here is a short cookbook on how to reproduce the problem on a test
server (no client needed to trigger the problem):

1) RedHat 7.3 with kernel 2.4.18-27.7.x
2) nfs-utils 1.0.5-1 (built with rpm -ta)
3) /etc/sysconfig/nfs
# For more information on nfs tuning, please see the NFS-HOWTO
# http://nfs.sourceforge.net/nfs-howto/
  
# Pass any additional options for mountd.
# MOUNTD_OPTIONS=
  
# Pin mountd to a given port rather than random one from portmapper
# MOUNTD_PORT=
  
# Don't advertise TCP for mount.
MOUNTD_TCP=no
  
# NFS V3
MOUNTD_NFS_V3=yes
  
# NFS V2
MOUNTD_NFS_V2=yes
  
# The number of open file descriptors
#MOUNTD_OPEN_FILES=128
  
# Pass the number of instances of nfsd (8 is default; 16 or more
# might be needed to handle heavy client traffic)
NFSDCOUNT=32
  
# Increase the memory limits on the socket input queues for
# the nfs processes .. NFS  benchmark SPECsfs demonstrate a
# need for a larger than default size (64kb) .. setting
# TUNE_QUEUE to yes will set the values to 256kb.
TUNE_QUEUE="yes"
NFS_QS=262144

4) create an exports file with 183 entries (here is exactly what I used,
in case the entries char length matters):
/home2/nfs/1 192.168.1.40(rw)
.
.
.
/home2/nfs/183 192.168.1.40(rw)

5) service nfslock start; service nfs start
6) issue `showmount -e`, it will show:
/home2/nfs/1 192.168.1.41
.
.
.
/home2/nfs/183 192.168.1.41

7) echo "/home2/nfs/184 192.168.1.40(rw)" >> /etc/exports
8) `exportfs -r` (rc 0)
9) `showmount -e` (rc 1: rpc mount export: RPC: Remote system error)

The moment I add the 184th entry to /etc/exports, `showmount -e` fails
with the same kind of error as amd does (host_fmount rpc failed: RPC:
Remote system error).

Now comes the interesting part, changing MOUNTD_TCP in
/etc/sysconfig/nfs from no to yes will make the problem go away. With
MOUNTD_TCP=yes I went up to 1000 exports and `showmount -e` worked fine.

To be honest, this is something I had changed in the same go when I
updated 1.0.3 to 1.0.5. So, for completeness, I ran the same tests with
1.0.3, the result is identical. For more than 183 entries and
MOUNTD_TCP=no, `showmount -e` returns the RPC error under 1.0.3, too.

I'm sorry about this, I should have investigated more carefully from
beginning on.

Greetings,
    Marc

On Fri, 2003-08-01 at 05:12, Neil Brown wrote:
> On  July 31, mschmitt@inf.ethz.ch wrote:
> > Hi all,
> > 
> > After upgrading a RedHat 7.3 box with kernel 2.4.18-27.7xsmp from
> > nfs-utils 1.0.3 to 1.0.5, amd stopped working.
> > 
> > On the client (am-utils-6.0.7-4, nfs-utils-0.3.3-6.73), I issue:
> > 
> > ls /net/<fileserver>
> > 
> > With 1.0.3, I get the correct directory listing under /net/<fileserver>
> > 
> > With 1.0.5, I get:
> > ls: /net/<fileserver>: Input/output error
> 
> Wierd.
> 
> > 
> > 
> > On the server, with 1.0.3, I'd see an entry for every export in
> > /etc/exports in /var/log/messages, mount refused or granted, according
> > to the export permissions. 
> > With 1.0.5, I get one single entry:
> > Jul 31 19:14:34 <fileserver> rpc.mountd: export request from <client>
> > 
> 
> Can you run
>    showmount -e <fileserver>
> on <client> and see what it returns?
> If it doesn't return the right stuff, maybe strace mountd on the
> server while you are running the showmout on the client.
> 
> NeilBrown



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
