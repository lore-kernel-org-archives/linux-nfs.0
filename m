From: dwight@supercomputer.org
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Tue, 30 Dec 2003 09:44:31 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200312301744.hBUHiVX01743@supercomputer.org>
References: <Charles.Lever@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: dwight@supercomputer.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AbN6G-0004ph-Fb
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 08:52:08 -0800
Received: from supercomputer.org ([69.17.34.169] helo=mail.supercomputer.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AbN6F-0003cK-SV
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 08:52:07 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: Message from "Lever, Charles" <Charles.Lever@netapp.com>
   of "Tue, 30 Dec 2003 07:50:39 PST." <482A3FA0050D21419C269D13989C611302B07B05@lavender-fe.eng.netapp.com>
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

Hi Charles,

> hi dwight-
> =

> i think "locking up" is a pretty general description of the
> problem.  we need to have precise details from wade about
> the server's behavior.  after all, it could be bad hardware,
> rather than any problem specific to the NFS implementation.

I agree; it could indeed be bad hardware. The point was that he should =

be fully updated with the latest patches from Sun first, before debugging=

an issue with Solaris.

But I must say that I'd be interested in knowing what packets are causing=

issues with Solaris, if that is the case, and Wade has the time to
provide that information. =


> > "Sensitive" should refer to performance. My experience is that
> > Linux NFS clients exhibit horrible performance issues with Sun
> > servers in standard, out-of-the-box configurations. That's in
> > comparison to using pure Sun or pure Linux Server/Client
> > combinations.
> =

> again, specific details about the problem would be very helpful.
> just saying that "they exhibit horrible performance out of the
> box" does not reflect the specifics of your environment, nor
> what kind of analysis and tuning you did to resolve the issues.
> was this a problem with default settings, or were there software,
> network, or hardware issues you encountered?

Thank you for asking. I was referring to standard RedHat releases (7.x on=
 up)
with the default settings. I'd be interested in knowing if you or anyone
else has any experience to the contrary.

As far as tuning goes, that gets rather extensive, from the MTU on up to =
the
NFS r/w sizes, as well as even the network topology. Since the options ar=
e
numerous and specific to one's environment, let me ask a simpler question=
: Has
anyone been able to tune a Linux-client and Solaris-server combination su=
ch
that the speed is comparable to a pure Linux or a pure Solaris client/ser=
ver
combination? This is for heavy r/w access. =


As far the networking topology goes, let us assume a simple isolated
configuration with just one dumb switch handling the client and server.
No NIS, no automounts, etc., etc; just simple NFS mounts. This is the typ=
e
of environment that I have been looking at the issue with lately.

	-dwight-





-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
