From: Greg Banks <gnb@sgi.com>
Subject: Re: Re: [PATCH] resend: knfsd multiple UDP sockets
Date: Tue, 8 Jun 2004 11:15:23 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040608011523.GB22272@sgi.com>
References: <20040528042007.GA9014@sgi.com> <16566.51874.43089.537506@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXVDJ-0008DJ-Eh
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 18:15:41 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BXVDJ-0005aY-0l
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 18:15:41 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16566.51874.43089.537506@cse.unsw.edu.au>
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

On Fri, May 28, 2004 at 03:14:10PM +1000, Neil Brown wrote:
> However if we could create a socket that was bound to an address only
> for sending and not for receiving, we could use a pool of such sockets
> for sending.
> This might be as easy as adding a "sk_norecv" field to struct sock,
> and skipping the sk->sk_prot->get_port call in inet_bind if it is set.
> Then all incoming requests would arrive on the one udp socket (there
> is very little contention between incoming packets on the one socket),
> and reply could go out one of the sk_norecv ports.
> 
> Does this make sense?  Would you be willing to try it?

In the last week I've looked at three options for bypassing the current
send limitation.

1.  Create multiple connected UDP sockets, and treat them just
    like connected TCP sockets, i.e. manage them in sv_tempsocks.

2.  Create a small pool of send-only sockets, as you describe.

3.  Use a single socket but reduce the time the svsk->sk_sem is
    held by building the datagram without the sem held and adding
    it to the write queue atomically.

It seems #2 is the easiest to implement.  #1 is next easiest but
would require either new hashing code in net/ipv4/udp.c or a logic
change to udp_v4_get_port(), neither of which appeal.  #3 is arguably
the right thing to do but is a very large chunk of work.

So I'm pursuing #2.  I think it can be done without touching the
UDP code.  More info when the patch gets some testing.


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
