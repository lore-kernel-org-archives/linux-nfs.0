From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH kNFSd 001 of 4] fix setattr-on-symlink error return
Date: Fri, 14 Oct 2005 15:35:23 -0400
Message-ID: <4350087B.9070908@redhat.com>
References: <20051014122041.11376.patches@notabene> <1051014022307.11542@cse.unsw.edu.au> <434FA4C4.6010806@redhat.com> <434FFBE4.2C502E98@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NeilBrown <neilb@cse.unsw.edu.au>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQVLM-0003bJ-2Y
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 12:35:52 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EQVLK-0003IV-Jc
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 12:35:51 -0700
To: James Yarbrough <jmy@sgi.com>
In-Reply-To: <434FFBE4.2C502E98@sgi.com>
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

James Yarbrough wrote:

>As I recall, the SpecFS tests exercise the NFS protocols directly, rather
>than through the filesystem interface provided by the client OS.
>
>Peter Staubach wrote:
>  
>
>>Just out of curiosity, how does the testsuite even generate a chmod(2)
>>request on a symbolic link?  The chmod(2) system call semantics should
>>not allow this.
>>    
>>

Are we talking about the SPEC SFS benchmark or something else?

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
