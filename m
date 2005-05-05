From: Kris Vassallo <kris@linuxcertified.com>
Subject: Re: Stale File handles keep coming back
Date: Wed, 04 May 2005 17:15:34 -0700
Message-ID: <1115252134.2523.87.camel@localhost.localdomain>
References: <1114463253.2487.73.camel@localhost.localdomain>
	 <17006.13241.129839.558300@cse.unsw.edu.au>
	 <1114554149.4470.5.camel@localhost.localdomain>
	 <17006.64544.860436.620665@cse.unsw.edu.au>
	 <4271DBB3.3090402@bio.ifi.lmu.de>  <42775C56.9000703@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-cURrwU/J8kqy/OHG0nOb"
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTU1s-0003EF-O3
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 17:15:48 -0700
Received: from meteor.hosting4less.com ([63.99.109.5])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DTU1r-0007R5-Ag
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 17:15:48 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <42775C56.9000703@bio.ifi.lmu.de>
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


--=-cURrwU/J8kqy/OHG0nOb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Tue, 2005-05-03 at 04:11, Frank Steiner wrote:

> Frank Steiner wrote
> 
> > minutes. After this time, they do a "ls" and get
> > 
> > ls: .: Stale NFS file handle
> > 
> > Calling "cd .." and then "cd <former_directory>", the ls works
> > again.

Ok a question for you. Let me explain what I am noticing: As soon as a
client gets the stale file error, I go to the actual NFS server, and do
a ls in the directory in question. Then without doing anything else, the
client does another ls and then the contents can be seen. I don't know
exactly what an ls does that would make the clients suddenly work again.

Are you able to do something similar?

-Kris


> 
> We just figured out that the files in the directory can be viewed when
> doing "ls specific_file":
> 
> wirth [13:09] lx003umv.default 55) ls -la
> ls: .: Stale NFS file handle
> wirth [13:10] lx003umv.default 56) ls -la defaults.ini
> -rw-------    1 tester   users          24 Apr 29 13:10 defaults.ini
> wirth [13:10] lx003umv.default 57) ls -la
> ls: .: Stale NFS file handle
> 
> So just "." goes stale, everything below seems to be sane. Maybe that
> info is helpful...
> 
> cu,
> Frank

--=-cURrwU/J8kqy/OHG0nOb
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.10">
</HEAD>
<BODY>
<BR>
On Tue, 2005-05-03 at 04:11, Frank Steiner wrote:
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>Frank Steiner wrote

&gt; minutes. After this time, they do a &quot;ls&quot; and get
&gt; 
&gt; ls: .: Stale NFS file handle
&gt; 
&gt; Calling &quot;cd ..&quot; and then &quot;cd &lt;former_directory&gt;&quot;, the ls works
&gt; again.</I></FONT></PRE>
</BLOCKQUOTE>
Ok a question for you. Let me explain what I am noticing: As soon as a client gets the stale file error, I go to the actual NFS server, and do a ls in the directory in question. Then without doing anything else, the client does another ls and then the contents can be seen. I don't know exactly what an ls does that would make the clients suddenly work again. <BR>
<BR>
Are you able to do something similar?<BR>
<BR>
-Kris<BR>
<BR>
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>
We just figured out that the files in the directory can be viewed when
doing &quot;ls specific_file&quot;:

wirth [13:09] lx003umv.default 55) ls -la
ls: .: Stale NFS file handle
wirth [13:10] lx003umv.default 56) ls -la defaults.ini
-rw-------    1 tester   users          24 Apr 29 13:10 defaults.ini
wirth [13:10] lx003umv.default 57) ls -la
ls: .: Stale NFS file handle

So just &quot;.&quot; goes stale, everything below seems to be sane. Maybe that
info is helpful...

cu,
Frank</I></FONT></PRE>
</BLOCKQUOTE>
</BODY>
</HTML>

--=-cURrwU/J8kqy/OHG0nOb--



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
