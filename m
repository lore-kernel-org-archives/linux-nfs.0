From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Not responding errors - what is it doing?
Date: 12 Jun 2003 22:37:19 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs3ciek06o.fsf@charged.uio.no>
References: <CFCD2C778CF1D611B5B400065B04D5C84A7525@KENTON>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QhFf-0000Wq-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Jun 2003 22:37:27 -0700
To: Edward Hibbert <EH@dataconnection.com>
In-Reply-To: <CFCD2C778CF1D611B5B400065B04D5C84A7525@KENTON>
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

>>>>> " " == Edward Hibbert <EH@dataconnection.com> writes:

     > Here's a rookie question.  I'm trying to track down the cause
     > of some server not responding errors against a SNAP Appliance
     > filer.  It would be useful to know how these are detected -
     > does the NFS client do a test, or is it in response to
     > application-issued operations?  What's the timeout value before
     > it will log this?

'man 5 nfs': look up 'timeo' and 'retrans'.

In recent kernels the UDP code also does its own round trip timing
estimation in order to work out when to retransmit.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
