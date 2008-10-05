From: "Marcelo Leal" <diversos-roWltSPQdMkZWYhx5MAOMFAUjnlXr6A1@public.gmane.org>
Subject: Re: Is NFS v4 stable and recommend to use now?
Date: Sat, 4 Oct 2008 21:20:33 -0300
Message-ID: <42996ba90810041720v583684a9x56d1d5e103fa37a5@mail.gmail.com>
References: <beaf78240810020949j703d95cvab1c44f33bff7019@mail.gmail.com>
	 <20081002171719.GA30408@fieldses.org>
	 <beaf78240810021034k3cb7db69p7ac458b8a3cfbb28@mail.gmail.com>
	 <20081003215247.GJ19057@fieldses.org>
	 <beaf78240810040634i672904c7g51e02855227a9d7c@mail.gmail.com>
	 <20081004204856.GB2777@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Roy M." <setesting001@gmail.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:41899 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbYJEAUe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Oct 2008 20:20:34 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2295595rvb.1
        for <linux-nfs@vger.kernel.org>; Sat, 04 Oct 2008 17:20:33 -0700 (PDT)
In-Reply-To: <20081004204856.GB2777@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 Actually, that is the reason why nfsv3 preformance does not scales
increasing the client's memory. I did a lot of tests about that (
http://www.posix.brte.com.br/blog/?p=89 ), and the overhead of the
protocol (to check the server informations about the file for
consistency), was the nfsv3 stopper. But NFS is a protocol for sharing
resources, and that is how it is supposed to work, no problem with
that. I think NFSv4 is handling that problem with some kind of
"delegation", where the client has "authority" on the filesystem or
file.. so, working more or less like iscsi in this regard.

 Leal.

2008/10/4 J. Bruce Fields <bfields@fieldses.org>:
> On Sat, Oct 04, 2008 at 09:34:49PM +0800, Roy M. wrote:
>> Hello,
>>
>> On Sat, Oct 4, 2008 at 5:52 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > I doubt the pattern of I/O really matters much--it's the opens and
>> > closes themselves that matter.
>> >
>> > (In v3, close-to-open cache consistency requires that the client always
>> > fetch file attributes from the server on an open.  That means open() is
>> > always going to take at least the ping time to the server.  In v4 in
>> > some situations the client can do the open with no call to the server at
>> > all--by comparison such an open is almost instantaneous.  If you're
>> > doing a ton of opens all in a row, that may make a difference.)
>> >
>>
>> In existing v3, you mean even if a file is cached locally by client,
>> in each open, the file attributes need to be read from NFS server
>> everytime?
>
> Right.  The client has to do that to check whether someone else has
> changed the file.  See http://nfs.sourceforge.net/#faq_a8 for an
> explanation of close-to-open cache consistency, which is what requires
> this.
>
>> But I just wonder without reading the NFS server, how the consistency
>> was maintained...
>
> I'm afraid I don't understand the question.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



-- 

[http://www.posix.brte.com.br/blog]
--------==== pOSix rules ====-------
