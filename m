From: s o f i a <sofiavalera@yahoo.com>
Subject: RE: Linux client network performance
Date: Thu, 26 Jun 2003 09:50:26 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030626165026.77910.qmail@web41804.mail.yahoo.com>
References: <482A3FA0050D21419C269D13989C6113127E5C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web41804.mail.yahoo.com ([66.218.93.138])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19VZxD-0006Uf-00
	for <nfs@lists.sourceforge.net>; Thu, 26 Jun 2003 09:50:35 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <482A3FA0050D21419C269D13989C6113127E5C@lavender-fe.eng.netapp.com>
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

Charles thank you so much for
your pointers.  I have downloaded
the Netapp paper, and will review
it....

> that's not a very clear description of the problem.
> it sounds like your client is retransmitting NFS
> write operations, but there isn't enough in your
> description to determine why that might occur.

yes you are right, and apologize for the
vague characterization ... the issue is actually:

I have an application that performs an "NFS-copy"
on an NFS Linux client.  This Linux client is
mounted to *source* volume in a Netapp Filer; 
copying files to an NFS mounted volume on a
*destination* host: SUN Solaris 8, VERITAS Foundation
Suite. both have GigE network adapters.
The application's data movement is NFS over UDP.

The symptom I saw was that, at about 30-50%
completion of the operation, we do see the client
retransmitting NFS write operations.  In fact,
in running tcpdump on the linux client and snoop
on the Solaris host, I saw the following sequence:

- NFS write attempt from client
- is received in destination
- NFS 2nd write attempt from client
- is received in destination
- destination sends back a reply
- NFS transaction completed.
... note: the host replies to the FIRST
NFS write_attempt, not the SECOND... therefore
based on timestamps.

any thoughts or comments will be most welcome.

thank you again,

 - s o f i a

__________________________________
Do you Yahoo!?
SBC Yahoo! DSL - Now only $29.95 per month!
http://sbc.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
