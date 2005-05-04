From: Kris Vassallo <kris@linuxcertified.com>
Subject: Re: Stale File handles keep coming back
Date: Wed, 04 May 2005 15:48:01 -0700
Message-ID: <1115246881.2523.14.camel@localhost.localdomain>
References: <1114463253.2487.73.camel@localhost.localdomain>
	 <17006.13241.129839.558300@cse.unsw.edu.au>
	 <1115155275.2894.20.camel@localhost.localdomain>
	 <42786148.1000201@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-MMuJqOtV7MR51GT5pPUh"
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTSfH-0000hr-4G
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 15:48:23 -0700
Received: from meteor.hosting4less.com ([63.99.109.5])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DTSfG-0000ad-81
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 15:48:22 -0700
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


--=-MMuJqOtV7MR51GT5pPUh
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

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

Bah! I changed it, no good. I did do it on a file system that was
already mounted but after I made the changes with tune2fs  I did a mount
-o remount and then a exportfs -r, I think that should have made it take
effect. 

> 
> I couldn't find any option to change this in reiserfs...

I don't remember who, but someone was using a suse kernel which was a
bit older than the fedora kernel I am using (2.6.11-1.14_FC3smp). I
found something interesting in the changelog on kernel.org that would
make me think that this issue was resolved in 2.6.11 but since I am
using 2.6.11 it either isn't fixed or the fedora team patched something
and broke the nfs fix. 
Take a look at the following. It would be interesting to see if the
2.6.11 release on Suse fixes this problem (although I don't know if this
has been released yet). 
http://kernel.org/pub/linux/kernel/v2.6/ChangeLog-2.6.11
And I quote "<trond.myklebust@fys.uio.no>

	NFSv2/v3/v4: ESTALE should not be a permanent condition on directories.
	
	Although it usually means that someone has deleted a file on the server,
	the ESTALE error may also indicate that the sysadmin has used exportfs to
	deny our client access to the server. Most NFS implementations therefore
	consider it a non-permanent condition, and allow inodes to "recover" when
	the sysadmin re-enables access.
	If, however, you want to work with broken servers, like unfsd, that reuse
	filehandles for new files after the original file gets deleted, then
	"recovery" is impossible, since it may be that the filehandle now points
	to a different file. Note that this is broken server behaviour that may
	happen even without us ever seeing the ESTALE error.
	In order to minimize (but we can never eliminate entirely) this race
	condition on unfsd servers, Linux has traditionally made ESTALE a
	permanent condition on all filehandles except the root filehandle.
	
	The problem is that if we apply this strict staleness criterion to
	directories (particularly so for he current directory), then all
	processes will need to re-walk the path starting from the mount point,
	in order to recover from the sysadmin intervention case. As this is not
	usual on other *NIX implementations, and may in any case be undermined by
	caching rules etc, this is being seen as a usability problem.
	
	This patch makes ESTALE a non-permanent condition on directories, but
	preserves the current behaviour for non-directories.
	
	Signed-off-by: Trond Myklebust <trond.myklebust@fys.uio.no>
"

-Kris


--=-MMuJqOtV7MR51GT5pPUh
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.10">
</HEAD>
<BODY>
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
explicitely changed it?</I></FONT></PRE>
</BLOCKQUOTE>
Bah! I changed it, no good. I did do it on a file system that was already mounted but after I made the changes with tune2fs&nbsp; I did a mount -o remount and then a exportfs -r, I think that should have made it take effect. 
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>
I couldn't find any option to change this in reiserfs...</I></FONT></PRE>
</BLOCKQUOTE>
I don't remember who, but someone was using a suse kernel which was a bit older than the fedora kernel I am using (2.6.11-1.14_FC3smp). I found something interesting in the changelog on kernel.org that would make me think that this issue was resolved in 2.6.11 but since I am using 2.6.11 it either isn't fixed or the fedora team patched something and broke the nfs fix. <BR>
Take a look at the following. It would be interesting to see if the 2.6.11 release on Suse fixes this problem (although I don't know if this has been released yet). <BR>
<A HREF="http://kernel.org/pub/linux/kernel/v2.6/ChangeLog-2.6.11">http://kernel.org/pub/linux/kernel/v2.6/ChangeLog-2.6.11</A><BR>
And I quote &quot;&lt;trond.myklebust@fys.uio.no&gt;
<PRE>	NFSv2/v3/v4: ESTALE should not be a permanent condition on directories.
	
	Although it usually means that someone has deleted a file on the server,
	the ESTALE error may also indicate that the sysadmin has used exportfs to
	deny our client access to the server. Most NFS implementations therefore
	consider it a non-permanent condition, and allow inodes to &quot;recover&quot; when
	the sysadmin re-enables access.
	If, however, you want to work with broken servers, like unfsd, that reuse
	filehandles for new files after the original file gets deleted, then
	&quot;recovery&quot; is impossible, since it may be that the filehandle now points
	to a different file. Note that this is broken server behaviour that may
	happen even without us ever seeing the ESTALE error.
	In order to minimize (but we can never eliminate entirely) this race
	condition on unfsd servers, Linux has traditionally made ESTALE a
	permanent condition on all filehandles except the root filehandle.
	
	The problem is that if we apply this strict staleness criterion to
	directories (particularly so for he current directory), then all
	processes will need to re-walk the path starting from the mount point,
	in order to recover from the sysadmin intervention case. As this is not
	usual on other *NIX implementations, and may in any case be undermined by
	caching rules etc, this is being seen as a usability problem.
	
	This patch makes ESTALE a non-permanent condition on directories, but
	preserves the current behaviour for non-directories.
	
	Signed-off-by: Trond Myklebust &lt;trond.myklebust@fys.uio.no&gt;
&quot;

-Kris
</PRE>
</BODY>
</HTML>

--=-MMuJqOtV7MR51GT5pPUh--



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
