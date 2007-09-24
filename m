From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS won't mount rw
Date: Mon, 24 Sep 2007 10:00:28 -0400
Message-ID: <46F7C2FC.1010908@redhat.com>
References: <46F460D9.1000105@aristoslogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chris Carlson <c.carlson@aristoslogic.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZoUJ-0005MI-IX
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 07:00:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZoUN-00039p-8L
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 07:00:44 -0700
In-Reply-To: <46F460D9.1000105@aristoslogic.com>
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

Chris Carlson wrote:
> We have a new problem that I was hoping someone could help with.
>
> We have a Snap Appliance NFS server.  It has been recently upgraded, so 
> it should have good NFS server software on it (though this isn't a 
> guarantee).
>
> We have a couple dozen Linux 2.4 systems that have it mounted (via 
> automount).  No problem.  All mount is with root_squash and rw (not sure 
> of the other options).
>
> We just tried to "automount" it to a RedHat Linux Enterprise 5 system, 
> and it mounted fine - except it is read-only.  Why would Linux 2.6 not 
> mount it rw like the other systems?  Is it some security thing that we 
> don't know?  Is there a bug in the NFS client on RH Linux?
>
> If anybody knows what we're missing, I'd appreciate a clue.

I don't suppose that this file system from the server is already
mounted somewhere on the client and is mounted there read-only?
The current RHEL-5 has a problem doing this.  It should be fixed
in the next release of RHEL-5.

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
