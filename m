From: Brian Kerr <kerrboy@gmail.com>
Subject: Re: nfs stale directory listings
Date: Mon, 24 Oct 2005 14:27:21 -0400
Message-ID: <b83c9e30510241127l40f382carb7032acd37e8fd9@mail.gmail.com>
References: <b83c9e30510131040v82885d2r407f5a12be93e30f@mail.gmail.com>
	 <1129225982.16119.1386.camel@rcsr01.cadence.com>
	 <b83c9e30510131120k117a8ac6q4a2d3a5ec7042cfd@mail.gmail.com>
	 <1129228138.16114.1394.camel@rcsr01.cadence.com>
	 <b83c9e30510131151w65a86078r668bd18c6a7b3bf7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EU72n-0002uE-PR
	for nfs@lists.sourceforge.net; Mon, 24 Oct 2005 11:27:37 -0700
Received: from xproxy.gmail.com ([66.249.82.194])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EU72m-0001KL-IZ
	for nfs@lists.sourceforge.net; Mon, 24 Oct 2005 11:27:37 -0700
Received: by xproxy.gmail.com with SMTP id s10so508386wxc
        for <nfs@lists.sourceforge.net>; Mon, 24 Oct 2005 11:27:21 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <b83c9e30510131151w65a86078r668bd18c6a7b3bf7@mail.gmail.com>
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

On 10/13/05, Brian Kerr <kerrboy@gmail.com> wrote:
> On 10/13/05, Chris Croswhite <csc@cadence.com> wrote:
> > do you mind mounting with sync option?  This will force write to disk
> > (in your case NFS disk).  This is what I did to make file appear
> > consistantly across the modest computer farm I work with.  e.g.
> > /etc/init.d/autofs- localoptions "sync".  Too, is there a reason you
> > chose soft mounts?
>
> I will try using the sync option - there is a performance hit
> associated with using that option though which may or may not be a
> problem.

The performance hit from forcing the sync option is rather dramatic,
10MByte/sec down to 1-2MByte/sec with sync enabled.

I doubt enabling the sync option will be a possibility with this huge
performance hit.


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
