From: Ion Badulescu <ionut@cs.columbia.edu>
Subject: Re: NFS retry on disconnection
Date: Mon, 13 May 2002 15:53:00 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200205131953.g4DJr0f30734@buggy.badula.org>
References: <OFAE43C5AB.44E1A1F2-ON87256BB8.00590C28@boulder.ibm.com>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bgp401130bgs.jersyc01.nj.comcast.net ([68.36.96.125] helo=buggy.badula.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177Lsi-0006cB-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 12:53:16 -0700
To: "Bryan Henderson" <hbryan@us.ibm.com>
In-Reply-To: <OFAE43C5AB.44E1A1F2-ON87256BB8.00590C28@boulder.ibm.com>
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

On Mon, 13 May 2002 09:17:54 -0700, Bryan Henderson <hbryan@us.ibm.com> wrote:

>>If you are adamant that you want all the aggravation of data loss,
>>programs crashing, user complaints, etc etc though, you can use the
>>'soft' mount option.
> 
> You sound like someone who has not faced the aggravation of resources that
> are hung indefinitely because communication has been lost with an NFS
> server which is no longer of any relevance to anything.  I'd say in many
> cases that must outweigh the aggravation of data loss and programs crashing
> and cause more user complaints.  Or do you have a way besides timeouts to
> ease that aggravation.

It's a lose-lose situation, and really the only proper way to fix the mess
is to bring the downed server back up.

Having NFS timeout underneath you is exactly the same as having a hard 
drive fail underneath you. Most if not all applications are utterly 
unprepared to deal with the resulting I/O errors, thus guaranteeing
data corruption.

The 'soft' mounting is only acceptable for read-only mounts, and even then
only if you really don't care about your input data disappearing at random.
That's AT RANDOM -- it's not a typo, you'll get RANDOM failures, depending
on how loaded your network and/or server are at times.

> Though you didn't answer the question, your advice implies that the Linux
> NFSv3 filesystem driver retries forever when communication with the NFS
> server has been lost.  If not, please correct us.

The default is 'hard' which will retry forever.

You can mount with '-o soft' which will give you the desired data corruption.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
