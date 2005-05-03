From: Kris Vassallo <kris@linuxcertified.com>
Subject: Re: Stale File handles keep coming back
Date: Tue, 03 May 2005 14:21:15 -0700
Message-ID: <1115155275.2894.20.camel@localhost.localdomain>
References: <1114463253.2487.73.camel@localhost.localdomain>
	 <17006.13241.129839.558300@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-ZBaJ/DmuGkWTCBSTN4Ro"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DT4pd-0005jd-GI
	for nfs@lists.sourceforge.net; Tue, 03 May 2005 14:21:29 -0700
Received: from meteor.hosting4less.com ([63.99.109.5])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DT4pb-00085s-UF
	for nfs@lists.sourceforge.net; Tue, 03 May 2005 14:21:29 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <17006.13241.129839.558300@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
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


--=-ZBaJ/DmuGkWTCBSTN4Ro
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

So in reference to this bug
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=150759
it seems as if ridding the system of the journal by instead using ext2
is fixing the problem? I can't tell if that bug has anything to do with
providing ESTALE errors but it seems to have the same effect where you
can't see files even though they are there. 

 Has anyone tried using the journal_data_ordered option? I am not sure
there is a way to do that in reiser but I know it can be done with ext3.
I am wondering if stuff is sitting in the journal and there is a lag
between writing in the journal and then having that data written to
disk. Using journal_data_ordered would theoretically fix that problem as
it would force the data to be written to the disk first. 
This is just a shot in the dark and I will let you know if I have any
success with this. Does anyone have any ideas on this?

-Kris

On Tue, 2005-04-26 at 05:27, Neil Brown wrote:

> On Monday April 25, kris@linuxcertified.com wrote:
> > I am experiencing a problem with stale file handles, and I have not been
> > able to find an answer in the archives nor has doing anything in the
> > readme helped. I apologize if an answer has already been posted
> > regarding an issue such as this. After many frustrating hours of
> > troubleshooting I am hoping for some help. The mail is long but I am
> > hoping that it answers all the questions. 
> 
> Very odd...
> 
> The output of:
> 
>   echo 2048 > /proc/sys/sunrpc/rpc_debug
>   grep . /proc/net/rpc/*/content
>   ls -l /proc/fs/nfsd
>   cat /proc/fs/nfs/exports
> 
> might help.
> 
> Thanks,
> NeilBrown
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--=-ZBaJ/DmuGkWTCBSTN4Ro
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.10">
</HEAD>
<BODY>
So in reference to this bug <A HREF="https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=150759">https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=150759</A><BR>
it seems as if ridding the system of the journal by instead using ext2 is fixing the problem? I can't tell if that bug has anything to do with providing ESTALE errors but it seems to have the same effect where you can't see files even though they are there. <BR>
<BR>
 Has anyone tried using the journal_data_ordered option? I am not sure there is a way to do that in reiser but I know it can be done with ext3. I am wondering if stuff is sitting in the journal and there is a lag between writing in the journal and then having that data written to disk. Using journal_data_ordered would theoretically fix that problem as it would force the data to be written to the disk first. <BR>
This is just a shot in the dark and I will let you know if I have any success with this. Does anyone have any ideas on this?<BR>
<BR>
-Kris<BR>
<BR>
On Tue, 2005-04-26 at 05:27, Neil Brown wrote:
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>On Monday April 25, kris@linuxcertified.com wrote:
&gt; I am experiencing a problem with stale file handles, and I have not been
&gt; able to find an answer in the archives nor has doing anything in the
&gt; readme helped. I apologize if an answer has already been posted
&gt; regarding an issue such as this. After many frustrating hours of
&gt; troubleshooting I am hoping for some help. The mail is long but I am
&gt; hoping that it answers all the questions. 

Very odd...

The output of:

  echo 2048 &gt; /proc/sys/sunrpc/rpc_debug
  grep . /proc/net/rpc/*/content
  ls -l /proc/fs/nfsd
  cat /proc/fs/nfs/exports

might help.

Thanks,
NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest &amp; candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.</FONT>
<A HREF="http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click"><U>http://ads.osdn.com/?ad_id=6595&amp;alloc_id=14396&amp;op=click</U></A>
<FONT COLOR="#737373">_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net</FONT>
<A HREF="https://lists.sourceforge.net/lists/listinfo/nfs"><U>https://lists.sourceforge.net/lists/listinfo/nfs</U></I></A></PRE>
</BLOCKQUOTE>
</BODY>
</HTML>

--=-ZBaJ/DmuGkWTCBSTN4Ro--



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
