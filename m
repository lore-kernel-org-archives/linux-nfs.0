From: "Paul Cunningham" <paulcunningham@sprintmail.com>
Subject: Re: rpc.mountd + rpc.nfsd
Date: Thu, 5 Sep 2002 08:08:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <024d01c254d4$ffb6b880$a985fea9@PAULSDESKTOP>
References: <3D7363A7.8090906@linkvest.com>	<15732.7907.19389.156631@notabene.cse.unsw.edu.au>	<3D745D10.4040409@linkvest.com>	<15732.35929.482032.954554@notabene.cse.unsw.edu.au>	<3D7490D4.7050307@linkvest.com> <15732.39741.104912.607715@notabene.cse.unsw.edu.au> <3D760B6D.2040408@linkvest.com> <3D77056C.6020500@linkvest.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
To: "Jean-Eric Cuendet" <jean-eric.cuendet@linkvest.com>,
	<nfs@sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>> If I understand you correctly, the nfs server will be on the same
>> machine as the nfs client that accesses that server. And then the
>> <..>
>> mounts itself and then starts responding to NFS requests.
>
> I REALLY need to know how to mount myself in a directory.
> I have nfs3_prot.x implemented but not mountd at all.
> How to do that? When in my program? What to call?

Short answer:  
You do not mount yourself in a directory.  mountd is used to retrieve 
the opaque file handle of the directory you wish to mount on the client.  
Once you have the initial opaque filehandle, you may then call an nfs 
procedure (ie. LOOKUP, READ, WRITE, READDIR, etc) with the
filehandle as one of the arguments.

Better answer:
As suggested by a previous reply, get yourself a copy of "NFS Illustrated"
by Brent Callaghan.





-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
