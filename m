From: "Dave Gilbert (Home)" <gilbertd@treblig.org>
Subject: Re: of rmtab and 'Invalid argument' and permission denied]
Date: Thu, 13 Mar 2003 13:43:48 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E708B14.1060000@treblig.org>
References: <20030309213151.GK747@gallifrey>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl-212-23-25-139.zen.co.uk ([212.23.25.139] helo=butternut.transitive.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18tT1v-0008AL-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Mar 2003 05:45:55 -0800
To: neilb@cse.unsw.edu.au,  nfs@lists.sourceforge.net
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

Neil Brown wrote thus:

    that I wrote:
>>Sometimes the client will get a permission denied on attempting to mount
>>from the server even though it managed it a few hours earlier with no
>>change to config of the server.
>>
>>Restarting the nfs server gives a line of the form:
>>
>>clienthostname: Invalid argument

> What does your /etc/exports file look like?  Does it have both host
> names and IP addresses?  
> Do you export both a directory and an ancestor of that directory on
> the same filesystem?
> 
> Both of these can cause this sort of problem.

Thank you!  It was exporting both a directory and an ancestor.
Can we have something which screams/shouts/warns/rejects this
rather than failing in an evil and confusing way?

(oh and add it to the NFS FAQ)

> What version of nfs-utils is in SuSE 8.1?
> 
>  showmount -v

showmount for nfs-utils 0.3.3

Dave



-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
