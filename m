From: Kris Vassallo <kris@linuxcertified.com>
Subject: Re: Stale File handles keep coming back
Date: Wed, 11 May 2005 18:01:34 -0700
Message-ID: <1115859694.23663.3.camel@localhost.localdomain>
References: <1114463253.2487.73.camel@localhost.localdomain>
	 <17006.13241.129839.558300@cse.unsw.edu.au>
	 <1115155275.2894.20.camel@localhost.localdomain>
	 <42786148.1000201@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-0qmmpXEVh6QY9teDk/iu"
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DW25G-0003jt-SB
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 18:01:50 -0700
Received: from meteor.hosting4less.com ([63.99.109.5])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DW25G-00089G-FO
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 18:01:50 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <42786148.1000201@bio.ifi.lmu.de>
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


--=-0qmmpXEVh6QY9teDk/iu
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Ok, well I have found very good success in killing this stupid stale
file handle problem in the 2.6.11 kernel by switching from ext3 to ext2
and then rebooting. For the past 5 days not 1 of my developers has
complained about this issue. 
Obviously if this machine goes down and a fsck starts running on the 750
GB of data, I am in some deep doo doo, but for now I am using this as a
way of getting around the problem until someone comes up with a nifty
patch. 
-Kris

On Tue, 2005-05-03 at 22:44, Frank Steiner wrote:

> Kris Vassallo wrote
> 
> > So in reference to this bug
> > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=150759
> > it seems as if ridding the system of the journal by instead using ext2
> > is fixing the problem? I can't tell if that bug has anything to do with
> > providing ESTALE errors but it seems to have the same effect where you
> > can't see files even though they are there. 
> 
> Yes, sounds very similar...
> 
> 
> > 
> >  Has anyone tried using the journal_data_ordered option? I am not sure
> > there is a way to do that in reiser but I know it can be done with ext3.
> 
> According to the man page, "data=ordered" is the default. Have you
> explicitely changed it?
> 
> I couldn't find any option to change this in reiserfs...

--=-0qmmpXEVh6QY9teDk/iu
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.10">
</HEAD>
<BODY>
Ok, well I have found very good success in killing this stupid stale file handle problem in the 2.6.11 kernel by switching from ext3 to ext2 and then rebooting. For the past 5 days not 1 of my developers has complained about this issue. <BR>
Obviously if this machine goes down and a fsck starts running on the 750 GB of data, I am in some deep doo doo, but for now I am using this as a way of getting around the problem until someone comes up with a nifty patch. <BR>
-Kris<BR>
<BR>
On Tue, 2005-05-03 at 22:44, Frank Steiner wrote:
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>Kris Vassallo wrote

&gt; So in reference to this bug
&gt; </FONT><A HREF="https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=150759"><U>https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=150759</U></A>
<FONT COLOR="#737373">&gt; it seems as if ridding the system of the journal by instead using ext2
&gt; is fixing the problem? I can't tell if that bug has anything to do with
&gt; providing ESTALE errors but it seems to have the same effect where you
&gt; can't see files even though they are there. 

Yes, sounds very similar...


&gt; 
&gt;  Has anyone tried using the journal_data_ordered option? I am not sure
&gt; there is a way to do that in reiser but I know it can be done with ext3.

According to the man page, &quot;data=ordered&quot; is the default. Have you
explicitely changed it?

I couldn't find any option to change this in reiserfs...</I></FONT></PRE>
</BLOCKQUOTE>
</BODY>
</HTML>

--=-0qmmpXEVh6QY9teDk/iu--



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
