From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: PATCH - SUNRPC 1 of 3 - The new "sk_flags" word in struct svc_sock must be long....
Date: 21 Aug 2002 01:16:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy9b1yvcz.fsf@charged.uio.no>
References: <15713.50328.541517.124690@notabene.cse.unsw.edu.au>
	<20020820185357.O21269@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hIET-0004RY-00
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 16:16:17 -0700
To: Benjamin LaHaise <bcrl@redhat.com>
In-Reply-To: <20020820185357.O21269@redhat.com>
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

>>>>> " " == Benjamin LaHaise <bcrl@redhat.com> writes:

     > On Tue, Aug 20, 2002 at 02:24:56PM +1000, Neil Brown wrote:
    >> @@ -22,7 +22,7 @@ struct svc_sock {
    >>
    >> struct svc_serv * sk_server; /* service for this socket */
    >> unsigned char sk_inuse; /* use count */
    >> - unsigned int sk_flags;
    >> + unsigned long sk_flags;

     > Cool, 7 bytes of useless padding on 64 bit architectures.

All down to the sad inability of certain 64-bit "processor architects"
to provide for atomic bit operations on 32-bit integers.
If the relatively minor bloat in knfsd worries you, then I advise you
to take a deep breath before peeking at struct page... 8-)

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
