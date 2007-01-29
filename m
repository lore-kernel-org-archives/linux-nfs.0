From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: rpc.gssd segfault on FC5 client
Date: Mon, 29 Jan 2007 17:44:20 -0500
Message-ID: <4d569c330701291444n36e3a891t318bcfe192c75a04@mail.gmail.com>
References: <1169911208.2767.15.camel@localhost.localdomain>
	<20070128230148.GB12125@fieldses.org>
	<1170030999.9144.8.camel@localhost.localdomain>
	<20070129010419.GF12125@fieldses.org>
	<1170079837.2871.15.camel@localhost.localdomain>
	<45BE5A87.3010204@CS.Arizona.EDU>
	<4d569c330701291402pa6760c4mf64cbfd82cfc6fd2@mail.gmail.com>
	<45BE6FF9.6000101@CS.Arizona.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jim Davis" <jdavis@cs.arizona.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBfEb-0007GF-V5
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 14:44:22 -0800
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBfEc-00025Q-IA
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 14:44:23 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1350325ugc
	for <nfs@lists.sourceforge.net>; Mon, 29 Jan 2007 14:44:21 -0800 (PST)
In-Reply-To: <45BE6FF9.6000101@CS.Arizona.EDU>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I'm not seeing nfs-utils-debuginfo available.  What is included with
nfs-utils-debuginfo-1.0.8.rc2-4.FC5.2 ?

On 1/29/07, Jim Davis <jdavis@cs.arizona.edu> wrote:
> Kevin Coffman wrote:
> >
> > I assume you have all the pre-reqs or it wouldn't start.  Just poking
> > around.  What do the following show?
> > "rpm -qa | grep nfs"
> > "rpm -qa | grep krb"
> >
> > What are the contents of /etc/gssapi_mech.conf?
>
>
> angora$ rpm -qa | grep nfs
> nfs-utils-1.0.8-4.fc5
> nfs-utils-lib-1.0.8-4.FC5
> system-config-nfs-1.3.19-1
> nfs-utils-debuginfo-1.0.8.rc2-4.FC5.2
> angora$ rpm -qa | grep krb
> krb5-devel-1.4.3-5.3
> krbafs-devel-1.2.2-9.2.1
> krb5-server-1.4.3-5.3
> krb5-workstation-1.4.3-5.3
> krbafs-1.2.2-9.2.1
> krb5-auth-dialog-0.6.cvs20060212-1.1
> krb5-libs-1.4.3-5.3
> pam_krb5-2.2.6-2.2
> krbafs-utils-1.2.2-9.2.1

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
