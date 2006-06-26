From: Neil Brown <neilb@suse.de>
Subject: Re: Number of nfsd processes?
Date: Mon, 26 Jun 2006 16:59:49 +1000
Message-ID: <17567.34277.247472.111371@cse.unsw.edu.au>
References: <40b437200606241759u3ec0ccd7q578c1ac476d498d9@mail.gmail.com>
	<17566.23170.136301.392306@cse.unsw.edu.au>
	<1151242251.23280.5.camel@pc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ful4s-0004nw-C2
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 00:00:10 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ful4p-0005L4-Qn
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 00:00:10 -0700
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
In-Reply-To: message from Brian J. Murrell on Sunday June 25
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

On Sunday June 25, brian@interlinx.bc.ca wrote:
> Neil,
> 
> Your description was a bit ungrokkable.  Let me try to put some real
> world values to it and try to make it out...

You seem to do OK.

> 
> On Sun, 2006-06-25 at 19:42 +1000, Neil Brown wrote:
> > Look at the line starting 'th'.
> 
> th 32 1439 108.420 17.016 6.044 3.724 2.464 0.296 0.256 0.280  0.672
> 
> >  The first number is the number of threads
> 
> Yup, 32 of them.
> 
> >  The second is the number of times the a thread has started handling
> >   a request when all other threads were busy
> 
> 1439 in my case.  I guess ideally you want this number quite low.  How
> low is low enough?

There isn't much useful information you can get out of this number.
Either it is unchanging (in which case you have plenty of threads,
maybe more than you need) or it is changing (in which case you
sometimes are using all your threads, but that might be OK).

> 
> >  The remainder are the number of seconds when
> >     0-10% of threads were in use
> 
> 108.420 seconds in my example.  By and far the largest value with the
> next one being only 17.016 seconds.

This suggests that most of the time you are using < 10% of your
threads - i.e. 1, 2, or 3.  But sometimes you use more.

> >     ...
> >    90-100%
> 
> 0.672
> 
> Quite low indeed, yes?

Yes. quite low.

> 
> > 
> >  From this you should be able to get an idea of how many threads
> >  are getting used.
> >  Ideally, the top few numbers
> 
> What do you mean by the "top few numbers"
> 
   th 32 1439 108.420 17.016 6.044 3.724 2.464 0.296 0.256 0.280  0.672
                                                     ^^^^^^^^^^^^^^^^^^
these ones.

> >  should be very small compared with the
> >  earlier numbers.
> 
> What do you mean by the "earlier numbers"?

   th 32 1439 108.420 17.016 6.044 3.724 2.464 0.296 0.256 0.280  0.672
                      ^^^^^^^^^^^^^^^^^^
These ones (roughly).

> 
> >   If they are, increase the number of threads.
> 
> So, should I increase threads?
> 

No.


> >  I usually run with 128, but there are probably 100-200 clients, but
> >  they aren't very busy clients.
> 
> Any WAGs (or better) on the "cost" of a thread?
> 

I'm not really sure of the cost (and I have no idea what a 'WAG' is).
Several pages of RAM at least.  Possibly something more than that.

NeilBrown

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
