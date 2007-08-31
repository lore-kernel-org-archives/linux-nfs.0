From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS performance "leak"  on 2.6.18?
Date: Fri, 31 Aug 2007 16:17:46 -0400
Message-ID: <1188591466.19730.50.camel@heimdal.trondhjem.org>
References: <OF47963A01.F14CACDA-ON85257348.006BD6E0-85257348.006D7305@lycos-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Joe.Pranevich@lycos-inc.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRCwG-00059A-D5
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 13:17:56 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IRCwJ-0007q2-OL
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 13:18:00 -0700
In-Reply-To: <OF47963A01.F14CACDA-ON85257348.006BD6E0-85257348.006D7305@lycos-inc.com>
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

On Fri, 2007-08-31 at 15:55 -0400, Joe.Pranevich@lycos-inc.com wrote:
> 
> Hello, 
> 
> Trond, we spoke about a year back because I had an obscure problem
> with deadlocks which, as it turned out, was being tickled by (but not
> in) the NFS code. You helped to point me in the right direction and I
> managed to get everything happy. I hope that maybe you can point me in
> the right direction again. 
> 
> I just upgraded one of our systems to RedHat AS/Centos 5 with their
> modified 2.6.18 kernel. I run Tripod.com/Angelfire.com, large free web
> providers all using Netapps/NFS behind our webservers. (There is a lot
> more architectural complexity than that, but that's the gist of it.)
> All NFSv3, of course. DataOnTap 7.x. 
> 
> I have a script which, when I run it immediately after a reboot (or
> nearly immediately) it takes 4 minutes to run. It does tons of very
> small reads and writes all over the place across 12 different NFS
> mounts, etc. After a day, the script takes 20 minutes to run. After
> two days, the script takes 40 minutes to run. (Approximately)
> Gradually, it takes longer and longer every day with no underlying
> change in load. (No processes stacking up, etc.) After a week or so of
> this, I have to reboot the entire farm and everything is fast again.
> While I use the example of this script, other NFS operations gradually
> seem to become slower. I can time "df" commands and see the same
> slowdown. Our web performance also times slower. 
> 
> Can you think of any known issues which I might be running into? I've
> sifted through your patches and will be adding them to my kernel, I'm
> recompiling something stock to make sure it's not a redhat addition,
> etc. But possibly you've seen this before and have a good
> recommendation? 
> 
> Any ideas? 

Have you looked at the 'nfsstat' statistics to check if there is any
difference between the number of NFS operations that is being performed
when the script takes 4 minutes to run, when it takes 20 minutes,
40,... ?

Cheers
  Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
