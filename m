From: Dejan Muhamedagic <dejan@hello-penguin.com>
Subject: Re: intermittent errors with AIX server
Date: Wed, 19 Feb 2003 23:31:46 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030219223146.GB1494@lilith.homenet>
References: <6440EA1A6AA1D5118C6900902745938E07D552B1@black.eng.netapp.com>
Reply-To: Dejan Muhamedagic <dejan@hello-penguin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from octopussy.utanet.at ([213.90.36.45])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lclM-0002a9-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 14:32:25 -0800
Received: from patricia.utanet.at ([213.90.36.8])
	by octopussy.utanet.at with esmtp (Exim 4.10)
	id 18lckp-0005OK-00
	for nfs@lists.sourceforge.net; Wed, 19 Feb 2003 23:31:51 +0100
Received: from dsl-155-224.utaonline.at ([62.218.155.224] helo=lilith.homenet)
	by patricia.utanet.at with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.10)
	id 18lckm-00030q-00
	for nfs@lists.sourceforge.net; Wed, 19 Feb 2003 23:31:49 +0100
Received: from lilith.homenet (localhost [127.0.0.1])
	by lilith.homenet (8.12.3/8.12.3/Debian -4) with ESMTP id h1JMVlMO002125
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 23:31:48 +0100
Received: (from dejan@localhost)
	by lilith.homenet (8.12.3/8.12.3/Debian -4) id h1JMVlc6002123
	for nfs@lists.sourceforge.net; Wed, 19 Feb 2003 23:31:47 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D552B1@black.eng.netapp.com>
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

Hi Charles,

On Fri, Feb 07, 2003 at 08:50:14AM -0800, Lever, Charles wrote:
> hi dejan-
> 
> > I've already switched from soft to hard,intr on Linux boxen a 
> > few hours ago and hope that will help.  If the errors 
> > persist, I will try with the tcp which should eventually fix 
> > the problem.
> 
> switching to hard will prevent corruption and probably allow
> your batch jobs to complete successfully, but i expect you
> will continue to see log messages with "timed out..." replaced
> by "retrying..." and some indication of when the server
> finally responded.

Oddly enough, there were "timed out" messages but they were not
accompanied by the "retrying..." ones.  Switching to the hard
mount option didn't help.  However...

> switching to TCP will lengthen the default retransmission
> timeout, which may make the log messages disappear too.
> 
> the problem may be that the NFS server on your AIX system is
> not responding quickly to some CREATE requests.  to tell what's
> really going on, you must capture a network trace between the
> client and server right as one of these messages occur.
> 
> there may be some background job on your AIX server that is
> consuming I/O bandwidth and preventing disk accesses from
> completing quickly.

... I will never find out what was the culprit because a colleague
installed the 2.4.20aa1 kernel in the meantime and now everything
is OK, i.e. no more timeouts.  I guess that there was a bug in the
2.4.20-ac2 kernel exposed by this particular hw configuration
which includes a Gb ethernet.

Thanks a lot for your help.

Cheers!

Dejan


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
